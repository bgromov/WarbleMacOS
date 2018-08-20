//
//  ble.swift
//  warble_macos
//
//  Created by 0xff on 18/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation
import CoreBluetooth
import Dispatch

typealias ScanCallback = @convention(c)(UnsafeRawPointer?, UnsafePointer<WarbleScanResult>) -> Void

class WarbleScanPrivateData {
    var uuids: [CBUUID] = []
    var mft: [UInt16:NSData] = [:]
}

class WarbleScanner: NSObject, CBCentralManagerDelegate {
    var cman: CBCentralManager
    weak var delegate:CBCentralManagerDelegate?
    var devices: [WarbleGatt] = []
    weak var centralQueue: DispatchQueue?

    var scanHandler: ScanCallback?
    var scanHandlerContext: UnsafeRawPointer?

    static let instance = WarbleScanner()

    override init() {
        //        queue = DispatchQueue(label: "com.github.bgromov.q", attributes: .concurrent)
        centralQueue = DispatchQueue.global()
        cman = CBCentralManager(delegate: nil, queue: centralQueue)
        super.init()
        cman.delegate = self
    }

    func setScanCallback(_ context: UnsafeRawPointer, _ cb: @escaping ScanCallback) {
        scanHandler = cb
        scanHandlerContext = context
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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let p = WarbleGatt(peripheral)
        p.mftData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSData
        devices.append(p)

        let mac = CStr(peripheral.identifier.uuidString)
        defer{mac.release()}
        let name = CStr(peripheral.name)
        defer{name.release()}
        var res = WarbleScanResult()

        res.mac = mac.get()
        res.name = name.get()
        res.rssi = Int32(truncating: RSSI)

        let priv = WarbleScanPrivateData()

        if p.mftData != nil {
            let company_id = p.mftData?.bytes.bindMemory(to: UInt16.self, capacity: 1).pointee
            priv.mft[company_id!] = NSData(bytes: p.mftData?.bytes.advanced(by: 2), length: (p.mftData?.length)! - 2)
        }

        let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [Any]
        if services != nil {
            priv.uuids = (services as? [CBUUID])!
//            print("Peripheral:", p.instance?.name, "UUIDs:", priv.uuids)
        }

        res.private_data = Unmanaged.passUnretained(priv).toOpaque()

        withUnsafePointer(to: &res) { (ptr) -> Void in
            scanHandler?(nil, UnsafePointer<WarbleScanResult>(ptr))
        }

//        print("Found [" + (peripheral.name ?? "Unknown") + "]: " + peripheral.identifier.uuidString)
    }
}
