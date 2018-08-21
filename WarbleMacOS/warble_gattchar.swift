//
//  warble_gattchar.swift
//  WarbleMacOS
//
//  Created by 0xff on 19/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation
import CoreBluetooth

class WarbleGattChar: NSObject {
    var instance: CBCharacteristic
    var service: CBService
    var peripheral: WarbleGatt

    var onWrite: FnVoid_VoidP_WarbleGattCharP_CharP?
    var onWriteContext: UnsafeMutableRawPointer?
    var onRead: FnVoid_VoidP_WarbleGattCharP_UbyteP_Ubyte_CharP?
    var onReadContext: UnsafeMutableRawPointer?
    var onNotify: FnVoid_VoidP_WarbleGattCharP_UbyteP_Ubyte?
    var onNotifyContext: UnsafeMutableRawPointer?
    var onNotifyEn: FnVoid_VoidP_WarbleGattCharP_CharP?
    var onNotifyEnContext: UnsafeMutableRawPointer?
    var onNotifyDis: FnVoid_VoidP_WarbleGattCharP_CharP?
    var onNotifyDisContext: UnsafeMutableRawPointer?


    init(peripheral: WarbleGatt, service: CBService, char: CBCharacteristic) {
        self.peripheral = peripheral
        self.service = service
        instance = char
        super.init()
    }
}
