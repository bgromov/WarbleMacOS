//
//  lib.swift
//  warble_macos
//
//  Created by 0xff on 19/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation

@_cdecl("warble_lib_version")
func warble_lib_version() -> UnsafePointer<Int8> {
    var cstr = CStr("0.0.1")
    defer {
        cstr.release()
    }
    return cstr.get()
}

@_cdecl("warble_lib_config")
func warble_lib_config() -> UnsafePointer<Int8> {
    var cstr = CStr(_isDebugAssertConfiguration() ? "Debug": "Release")
    defer {
        cstr.release()
    }
    return cstr.get()
}

func warble_lib_init(_ nopts: Int32, _ opts: UnsafePointer<WarbleOption>) {

}
