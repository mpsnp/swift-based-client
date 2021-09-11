//
//  DispatchSemaphore+Ext.swift
//  
//
//  Created by Alexander van der Werff on 11/09/2021.
//

import Foundation

#if os(Linux)
import Dispatch
#endif

extension DispatchSemaphore {
    @discardableResult
    func with<T>(_ block: () throws -> T) rethrows -> T {
        wait()
        defer { signal() }
        return try block()
    }
}
