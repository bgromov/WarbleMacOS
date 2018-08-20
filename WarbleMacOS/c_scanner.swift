//
//  scanner.swift
//  warble_macos
//
//  Created by 0xff on 19/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation
import CoreBluetooth

private let bleScanner = WarbleScanner.instance

@_cdecl("warble_scanner_set_handler")
func warble_scanner_set_handler(_ context: UnsafeRawPointer, _ handler: @escaping ScanCallback)
{
    bleScanner.setScanCallback(context, handler)
}

@_cdecl("warble_scanner_start")
func warble_scanner_start(_ nopts: Int32, _ opts: UnsafePointer<WarbleOption>) {
    let c_opts = UnsafeBufferPointer(start: opts, count: Int(nopts))

    var options = [String: String]()
    for opt in c_opts {
        let key: String = String(cString: opt.key)
        let value: String = String(cString: opt.value)
        options[key] = value
    }

    bleScanner.startScan()
}

@_cdecl("warble_scanner_stop")
func warble_scanner_stop() {
    bleScanner.stopScan()
}

@_cdecl("warble_scan_result_get_manufacturer_data")
func warble_scan_result_get_manufacturer_data(_ result: UnsafePointer<WarbleScanResult>, _ company_id: UInt16) -> UnsafePointer<WarbleScanMftData>? {
    if result.pointee.private_data == nil {
        return nil
    }

    let priv = Unmanaged<WarbleScanPrivateData>.fromOpaque(result.pointee.private_data).takeUnretainedValue()

    if priv.mft[company_id] != nil {
        var mft_data = WarbleScanMftData()

        mft_data.value = priv.mft[company_id]!.bytes.assumingMemoryBound(to: UInt8.self)
        mft_data.value_size = UInt32(priv.mft[company_id]!.length)

        let raw_data = withUnsafePointer(to: &mft_data) {(ptr) -> NSData in
            return NSData(bytes: ptr, length: MemoryLayout<WarbleScanMftData>.size)
        }

        return raw_data.bytes.assumingMemoryBound(to: WarbleScanMftData.self)
    }

    return nil
}

@_cdecl("warble_scan_result_has_service_uuid")
func warble_scan_result_has_service_uuid(_ result: UnsafePointer<WarbleScanResult>, _ uuid: UnsafePointer<Int8>) -> Int32 {
    if result.pointee.private_data != nil {
        let priv = Unmanaged<WarbleScanPrivateData>.fromOpaque(result.pointee.private_data).takeUnretainedValue()
        if priv.uuids.isEmpty {
            return 0
        }

        let u = CBUUID(string: String(cString: uuid))
        return priv.uuids.contains(u) ? 1 : 0
    }

    return 0
}
