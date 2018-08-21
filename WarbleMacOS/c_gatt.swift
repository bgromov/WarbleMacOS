//
//  gatt.swift
//  WarbleMacOS
//
//  Created by 0xff on 19/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation
import CoreBluetooth

private let central = WarbleCentral.instance

/**
 * Creates a WarbleGatt object
 * @param mac           mac address of the remote device e.g. CB:B7:49:BF:27:33
 * @return Pointer to the newly created object
 */
@_cdecl("warble_gatt_create")
func warble_gatt_create(_ mac: UnsafePointer<Int8>) -> OpaquePointer? {
    let gatt = central.create(mac: String(cString: mac))
    if gatt != nil {
        return opaquePointerFromObject(obj: gatt!)
    }

    return nil
}

/**
 * Creates a WarbleGatt object
 * @param mac           mac address of the remote device e.g. CB:B7:49:BF:27:33
 * @return Pointer to the newly created object
 */
@_cdecl("warble_gatt_create_with_options")
func warble_gatt_create_with_options(_ nopts: Int32, _ opts: UnsafePointer<WarbleOption>) -> OpaquePointer? {
    let c_opts = UnsafeBufferPointer(start: opts, count: Int(nopts))

    var options = [String: String]()
    for opt in c_opts {
        let key: String = String(cString: opt.key)
        let value: String = String(cString: opt.value)
        options[key] = value
    }

    let mac = options["mac"]
    if mac != nil {
        let gatt = central.create(mac: mac!)
        if gatt != nil {
            return opaquePointerFromObject(obj: gatt!)
        }
    }

    return nil
}

/**
 * Frees the memory allocated for the WarbleGatt object
 * @param obj           Object to delete
 */
@_cdecl("warble_gatt_delete")
func warble_gatt_delete(_ obj: OpaquePointer) -> Void {
    let gatt: WarbleGatt? = objectFromOpaquePointer(obj_ptr: obj)

//    if gatt == nil {
//        return
//    }

    central.delete(gatt: gatt!)
}

/**
 * Connects to the remote device
 * @param obj           Calling object
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when the connect task is completed
 */
@_cdecl("warble_gatt_connect_async")
func warble_gatt_connect_async(_ obj: OpaquePointer, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattP_CharP) -> Void {
    let gatt: WarbleGatt? = objectFromOpaquePointer(obj_ptr: obj)

//    if gatt == nil {
//        return
//    }

    central.connectAsync(gatt: gatt!, context: context, cb: handler)
}

/**
 * Disconnects from the remot device.  The callback function set in <code>warble_gatt_on_disconnect</code> will be called
 * after all resources are freed
 * @param obj           Calling object
 */
@_cdecl("warble_gatt_disconnect")
func warble_gatt_disconnect(_ obj: OpaquePointer) -> Void {
    let gatt: WarbleGatt? = objectFromOpaquePointer(obj_ptr: obj)

//    if gatt == nil {
//        return
//    }

    central.disconnect(gatt: gatt!)
}

/**
 * Sets a handler to listen for disconnect events
 * @param obj           Calling object
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when a disconnect event is received
 */
@_cdecl("warble_gatt_on_disconnect")
func warble_gatt_on_disconnect(_ obj: OpaquePointer, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattP_Int) -> Void {
    let gatt: WarbleGatt? = objectFromOpaquePointer(obj_ptr: obj)
//    if gatt == nil {
//        return
//    }
    central.setOnDisconnect(gatt: gatt!, context: context, cb: handler)
}

/**
 * Checks the current connection status
 * @param obj           Calling object
 * @return 0 if there is no active connect, non-zero if connected
 */
@_cdecl("warble_gatt_is_connected")
func warble_gatt_is_connected(_ obj: OpaquePointer) -> Int32 {
    let gatt: WarbleGatt? = objectFromOpaquePointer(obj_ptr: obj)
//    if gatt == nil {
//        return 0;
//    }
    return central.isConnected(gatt: gatt) ? 1 : 0
}

/**
 * Checks if a GATT characteristic exists with the uuid
 * @param obj           Calling object
 * @param uuid          128-bit string representation of the uuid
 * @return WarbleGattChar pointer if characteristic exists, null otherwise
 */
@_cdecl("warble_gatt_find_characteristic")
func warble_gatt_find_characteristic(_ obj: OpaquePointer, uuid: UnsafePointer<Int8>) -> OpaquePointer? {
    let gatt: WarbleGatt? = objectFromOpaquePointer(obj_ptr: obj)
    let gattchar: WarbleGattChar? = gatt?.findCharacteristic(uuidString: String(cString: uuid))

    return opaquePointerFromObject(obj: gattchar)
}

/**
 * Checks if a GATT service exists with the uuid
 * @param obj           Calling object
 * @param uuid          128-bit string representation of the uuid
 * @return 0 if there service does not exists, non-zero otherwise
 */
@_cdecl("warble_gatt_has_service")
func warble_gatt_has_service(_ obj: OpaquePointer, uuid: UnsafePointer<Int8>) -> Int32 {
    let gatt: WarbleGatt? = objectFromOpaquePointer(obj_ptr: obj)
//    if gatt == nil {
//        return 0;
//    }

    let uuidString = String(cString: uuid)

    return gatt!.hasService(uuidString: uuidString) ? 1 : 0;
}
