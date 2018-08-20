//
//  utils.swift
//  warble_macos
//
//  Created by 0xff on 19/08/2018.
//  Copyright © 2018 0xff. All rights reserved.
//

import Foundation

class CStr {
    let cstr: UnsafeMutablePointer<Int8>
    init(_ str: String?) {
        guard let ptr = strdup(str ?? "") else {fatalError("Failed to strdup")}
        cstr = ptr
    }
    func release() {
        free(cstr)
    }
    func get() -> UnsafePointer<Int8> {
        return UnsafePointer(cstr)
    }
}

func opaquePointerFromObject<T: NSObject>(obj: T) -> OpaquePointer? {
    let obj_ptr = Unmanaged.passUnretained(obj).toOpaque()
    return OpaquePointer(obj_ptr)
}

func objectFromOpaquePointer<T: NSObject>(obj_ptr: OpaquePointer) -> T {
    let obj = Unmanaged<T>.fromOpaque(UnsafeRawPointer(obj_ptr)).takeUnretainedValue()
    return obj
}
