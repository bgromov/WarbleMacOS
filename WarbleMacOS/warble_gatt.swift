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

class WarbleCallback<T> {
    let context: UnsafeRawPointer?
    let handler: T?

    init(context: UnsafeRawPointer?, handler: T?) {
        self.handler = handler
        self.context = context
    }
}

class WarbleGatt: NSObject, CBPeripheralDelegate {
    var instance: CBPeripheral?
    var mftData: NSData?
    var queue: DispatchQueue?
    var services_map: [CBUUID: CBService] = [:]
    var chars_map: [CBUUID : WarbleGattChar] = [:]

    var onDisconnect: FnVoid_VoidP_WarbleGattP_Int?
    var onDisconnectContext: UnsafeMutableRawPointer?
    var onConnect: FnVoid_VoidP_WarbleGattP_CharP?
    var onConnectContext: UnsafeMutableRawPointer?

    let services_sem = DispatchSemaphore(value: 0)
    let chars_sem = DispatchSemaphore(value: 0)

    init(_ peripheral: CBPeripheral) {
        super.init()
        queue = DispatchQueue.global()
        instance = peripheral
        instance!.delegate = self
    }

    func hasService(uuidString: String) -> Bool {
        if services_map.isEmpty {
            discoverServices()
        }
        return services_map[CBUUID(string: uuidString)] == nil ? false : true
    }

    func discoverServices() {
        DispatchQueue.global().async {
//            print("s-")
            self.instance?.discoverServices(nil)
        }
        services_sem.wait()

        for s in instance!.services! {
            services_map[s.uuid] = s
        }
    }

    func discoverCharacteristics() {
        if chars_map.isEmpty {
            if services_map.isEmpty {
                discoverServices()
            }
            for s in services_map.values {
                DispatchQueue.global().async {
//                    print("c-")
                    self.instance!.discoverCharacteristics(nil, for: s)
                }
                chars_sem.wait()
            }
        }
    }

    func findCharacteristic(uuidString: String) -> WarbleGattChar? {
        if chars_map.isEmpty {
            discoverCharacteristics()
        }
        return chars_map[CBUUID(string: uuidString)]
    }

    func writeChar(char: WarbleGattChar, value: Data, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) {
        char.onWrite = cb
        char.onWriteContext = context

        DispatchQueue.global().async {
            self.instance?.writeValue(value, for: char.instance, type: .withResponse)
        }
    }

    func writeCharNoResponse(char: WarbleGattChar, value: Data, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) {
        char.onWrite = cb
        char.onWriteContext = context

        instance?.writeValue(value, for: char.instance, type: .withoutResponse)
        char.onWrite?(char.onWriteContext, opaquePointerFromObject(obj: char), nil)
    }

    func readChar(char: WarbleGattChar, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattCharP_UbyteP_Ubyte_CharP) {
        char.onRead = cb
        char.onReadContext = context

        DispatchQueue.global().async {
            self.instance?.readValue(for: char.instance)
        }
    }

    func enableNotifications(char: WarbleGattChar, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) {
        char.onNotifyEn = cb
        char.onNotifyEnContext = context

        char.isNotifyEnRequested = true

        DispatchQueue.global().async {
            self.instance?.setNotifyValue(true, for: char.instance)
        }
    }

    func disableNotifications(char: WarbleGattChar, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) {
        char.onNotifyDis = cb
        char.onNotifyDisContext = context

        char.isNotifyDisRequested = true

        DispatchQueue.global().async {
            self.instance?.setNotifyValue(false, for: char.instance)
        }
    }

    func setNotificationsCallback(char: WarbleGattChar, context: UnsafeMutableRawPointer, cb: @escaping FnVoid_VoidP_WarbleGattCharP_UbyteP_Ubyte) {
        char.onNotify = cb
        char.onNotifyContext = context
    }

//---------- Delegate methods -----------

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        for s in peripheral.services! {
//            print(s)
//        }
        services_sem.signal()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for c in service.characteristics! {
            chars_map[c.uuid] = WarbleGattChar(peripheral: self, service: service, char: c)
//            print(c)
        }
        chars_sem.signal()
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        var cstr: CStr?
        defer {
            if cstr != nil {
                cstr!.release()
            }
        }
        if error != nil {
            cstr = CStr(error!.localizedDescription)
        }
        DispatchQueue.global().async {
            let gattchar = self.chars_map[characteristic.uuid]
            gattchar?.onWrite?(gattchar?.onWriteContext, opaquePointerFromObject(obj: gattchar), cstr?.get())
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var cstr: CStr?
        defer {
            if cstr != nil {
                cstr!.release()
            }
        }
        if error != nil {
            cstr = CStr(error!.localizedDescription)
        }
        DispatchQueue.global().async {
            let gattchar = self.chars_map[characteristic.uuid]
            let data = characteristic.value!

            data.withUnsafeBytes({(ptr: UnsafePointer<UInt8>) -> Void in
                gattchar?.onRead?(gattchar?.onReadContext,
                                  opaquePointerFromObject(obj: gattchar),
                                  ptr,
                                  UInt8(data.count),
                                  cstr?.get())
                if characteristic.isNotifying {
                    gattchar?.onNotify?(gattchar?.onNotifyContext,
                                      opaquePointerFromObject(obj: gattchar),
                                      ptr,
                                      UInt8(data.count))
                }
            })
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        var cstr: CStr?
        defer {
            if cstr != nil {
                cstr!.release()
            }
        }
        if error != nil {
            cstr = CStr(error!.localizedDescription)
        }
        DispatchQueue.global().async {
            let gattchar = self.chars_map[characteristic.uuid]

            if gattchar!.isNotifyEnRequested {
                gattchar?.onNotifyEn?(gattchar?.onNotifyEnContext,
                                      opaquePointerFromObject(obj: gattchar),
                                      cstr?.get()
                )
                gattchar!.isNotifyEnRequested = false
            }
            if gattchar!.isNotifyDisRequested {
                gattchar?.onNotifyDis?(gattchar?.onNotifyEnContext,
                                      opaquePointerFromObject(obj: gattchar),
                                      cstr?.get()
                )
                gattchar!.isNotifyDisRequested = false
            }
        }
    }

}
