//
//  warble_blecentral.swift
//  WarbleMacOS
//
//  Created by 0xff on 20/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation
import CoreBluetooth

class WarbleCentral: NSObject, CBCentralManagerDelegate {
    var cman: CBCentralManager
    weak var delegate:CBCentralManagerDelegate?
    var devices: [CBPeripheral : WarbleGatt] = [:]
    weak var centralQueue: DispatchQueue?

    let connectSemaphore = DispatchSemaphore(value: 0)

    static let instance = WarbleCentral()

    var mac: String?

    private override init() {
        centralQueue = DispatchQueue.global()
        //        centralQueue = DispatchQueue.main
        //        centralQueue = nil
        cman = CBCentralManager(delegate: nil, queue: centralQueue)
        super.init()
        cman.delegate = self
    }

    func create(mac: String) -> WarbleGatt? {
        var peripherals = cman.retrievePeripherals(withIdentifiers: [UUID(uuidString: mac)!])
        if peripherals.isEmpty {
            return nil
        }
        let gatt = WarbleGatt(peripherals[0])
        devices[gatt.instance!] = gatt
        return gatt
    }

    func delete(gatt: WarbleGatt) {
        devices.removeValue(forKey: gatt.instance!)
    }

    func connectAsync(gatt: WarbleGatt, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattP_CharP) {
        gatt.onConnectContext = context
        gatt.onConnect = cb

//        print("Connecting?")
        self.cman.connect(gatt.instance!)

        DispatchQueue.global().async {
            while gatt.instance!.state != .connected && RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantFuture) {}
        }

        //        DispatchQueue.main.async {
        //            print("Yes")
        //            self.cman.connect(gatt.instance!)
        //            while gatt.instance!.state != .connected {
        //                RunLoop.main.run(mode: .defaultRunLoopMode , before: .distantPast)
        //            }
        ////            self.connectSemaphore.signal()
        //        }
//        print("Async!")
        //        connectSemaphore.wait()
        //        connectGroup.wait()
    }

    func isConnected(gatt: WarbleGatt?) -> Bool {
        if gatt != nil {
            let p = gatt!.instance
            if p != nil {
                if devices[p!] != nil {
                    return p!.state == .connected
                }
            }
        }

        return false
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let gatt = devices[peripheral]!
        let obj_ptr = Unmanaged.passRetained(gatt).toOpaque()
        DispatchQueue.global().async {
            gatt.onConnect?(gatt.onConnectContext, OpaquePointer(obj_ptr), nil)
        }
//        print("Did connect!")

        //        connectGroup.leave()
        //        self.connectSemaphore.signal()
    }

    func setOnDisconnect(gatt: WarbleGatt, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattP_Int) {
        gatt.onDisconnectContext = context
        gatt.onDisconnect = cb
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let gatt = devices[peripheral]!

        let obj_ptr = Unmanaged.passRetained(gatt).toOpaque()
        DispatchQueue.global().async {
            gatt.onDisconnect?(gatt.onDisconnectContext, OpaquePointer(obj_ptr), 0)
        }
//        print("Did disconnect!")
    }

    func disconnect(gatt: WarbleGatt) {
        cman.cancelPeripheralConnection(gatt.instance!)
    }

    func startScan() {
        while cman.state != .poweredOn {
            RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantPast)
        }

        if cman.state == .poweredOn {
            cman.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
    }

    func stopScan() {
        if cman.state == .poweredOn && cman.isScanning {
            cman.stopScan()
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //        print("newState:", central.state.rawValue)
    }

}
