//
//  gattchar.swift
//  WarbleMacOS
//
//  Created by 0xff on 19/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation
import CoreBluetooth
import Dispatch

/**
 * Writes the value to the characteristic, requesting a response from the remote device
 * @param obj           Calling object
 * @param value         Pointer to the first byte to write
 * @param len           Number of bytes to write
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when the async task has completed
 */
@_cdecl("warble_gattchar_write_async")
func warble_gattchar_write_async(_ obj: OpaquePointer, _ value: UnsafePointer<UInt8>, _ len: UInt8, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) -> Void
{

}

/**
 * Writes the value to the characteristic without requiring a response from the remote device
 * @param obj           Calling object
 * @param value         Pointer to the first byte to write
 * @param len           Number of bytes to write
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when the async task has completed
 */
@_cdecl("warble_gattchar_write_without_resp_async")
func warble_gattchar_write_without_resp_async(_ obj: OpaquePointer, _ value: UnsafePointer<UInt8>, _ len: UInt8, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) -> Void
{

}

/**
 * Reads the current value of the characteristic from the remote device
 * @param obj           Calling object
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when the async task has completed
 */
@_cdecl("warble_gattchar_read_async")
func warble_gattchar_read_async(_ obj: OpaquePointer, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattCharP_UbyteP_Ubyte_CharP) -> Void
{

}

/**
 * Enables notifications on the characteristic
 * @param obj           Calling object
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when the async task has completed
 */
@_cdecl("warble_gattchar_enable_notifications_async")
func warble_gattchar_enable_notifications_async(_ obj: OpaquePointer, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) -> Void
{

}

/**
 * Disables notifications on the characteristic
 * @param obj           Calling object
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when the async task has completed
 */
@_cdecl("warble_gattchar_disable_notifications_async")
func warble_gattchar_disable_notifications_async(_ obj: OpaquePointer, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattCharP_CharP) -> Void
{

}

/**
 * Sets a handler to listen for characteristic notifications
 * @param obj           Calling object
 * @param context       Additional data for the callback function
 * @param handler       Callback function that is executed when notifications are received
 */
@_cdecl("warble_gattchar_on_notification_received")
func warble_gattchar_on_notification_received(_ obj: OpaquePointer, _ context: UnsafeMutableRawPointer, _ handler: @escaping FnVoid_VoidP_WarbleGattCharP_UbyteP_Ubyte) -> Void
{

}

/**
 * Gets the string representation of the characteristic's uuid
 * @param obj           Calling object
 * @return String representation of the 128-bit uuid
 */
@_cdecl("warble_gattchar_get_uuid")
func warble_gattchar_get_uuid(_ obj: OpaquePointer) -> UnsafePointer<Int8>?
{
    return nil
}

/**
 * Gets the WarbleGatt object that the characteristic belongs to
 * @param obj           Calling object
 * @return Pointer to the owning WarbleGatt object
 */
@_cdecl("warble_gattchar_get_gatt")
func warble_gattchar_get_gatt(_ obj: OpaquePointer) -> OpaquePointer?
{
    return nil
}
