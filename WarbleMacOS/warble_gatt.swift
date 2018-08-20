//
//  warble_gatt.swift
//  WarbleMacOS
//
//  Created by 0xff on 19/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation
import CoreBluetooth
import Dispatch

//class WarbleCallback<T> {
//    let handler: T?
//    let context: UnsafeRawPointer?
//
//    init(handler: T?, context: UnsafeRawPointer?) {
//        handler = handler
//        context = context
//    }
//
//    func call(
//}

class WarbleGatt: NSObject, CBPeripheralDelegate {
    var instance: CBPeripheral?
    var mftData: NSData?
    var queue: DispatchQueue?

    var onDisconnect: FnVoid_VoidP_WarbleGattP_Int?
    var onDisconnectContext: UnsafeMutableRawPointer?
    var onConnect: FnVoid_VoidP_WarbleGattP_CharP?
    var onConnectContext: UnsafeMutableRawPointer?

    init(_ peripheral: CBPeripheral) {
        super.init()
        queue = DispatchQueue.global()
        instance = peripheral
        instance!.delegate = self
    }

    func discoverServices() {
        instance?.discoverServices(nil)
        let group = DispatchGroup()
        group.enter()

//        DispatchQueue.global().async {
//            while (self.instance?.services == nil) {
//                RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantPast)
//                RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantPast)
//                sleep(1)
//                print("run")
//            }
            print("done")
            group.leave()
//        }
        print("waiting...")
        group.wait()
        print("complete")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for s in peripheral.services! {
            print(s)
        }
    }
}

class WarbleCentral: NSObject, CBCentralManagerDelegate {
    var cman: CBCentralManager
    weak var delegate:CBCentralManagerDelegate?
    var devices: [CBPeripheral : WarbleGatt] = [:]
    weak var centralQueue: DispatchQueue?

    static let instance = WarbleCentral()

    var mac: String?

    private override init() {
        centralQueue = DispatchQueue.global()
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

        cman.connect(gatt.instance!)
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
        gatt.onConnect?(gatt.onConnectContext, OpaquePointer(obj_ptr), nil)
    }

    func setOnDisconnect(gatt: WarbleGatt, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattP_Int) {
        gatt.onDisconnectContext = context
        gatt.onDisconnect = cb
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let gatt = devices[peripheral]!

        let obj_ptr = Unmanaged.passRetained(gatt).toOpaque()
        gatt.onDisconnect?(gatt.onDisconnectContext, OpaquePointer(obj_ptr), 0)
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
