//
//  Emitter.swift
//  
//
//  Created by Alexander van der Werff on 04/09/2021.
//

import Foundation

#if os(Linux)
import Dispatch
#endif

fileprivate class Listener<T> {
    let listener: ((T) -> ())
    let once: Bool

    init(_ listener: @escaping ((T) -> ()), _ once: Bool = false) {
        self.once = once
        self.listener = listener
    }

    init(_ listener: @escaping (() -> ()), _ once: Bool = false) {
        self.once = once
        self.listener = { (_: T) -> () in
            listener()
        }
    }
}

class Emitter {
    
    private let lock = DispatchSemaphore(value: 1)
    
    private var listeners: [String: [Any]] = [:]

    func emit(type: String) {
        listeners[type]?.forEach {
            emit(type, $0, ())
        }
    }
    
    func emit<T>(type: String, _ val: T) {
        listeners[type]?.forEach {
            emit(type, $0, val)
        }
    }
    
    private func emit<T>(_ type: String, _ listener: Any, _ val: T) {
        let wrapper = listener as? Listener<T>
        wrapper?.listener(val)
        if wrapper?.once ?? false {
            removeListener(type, wrapper)
        }
    }

    func on(_ type: String, _ fn: @escaping () -> ()) {
        let listener = Listener<Void>(fn)
        on(type, listener)
    }

    func on<T>(_ type: String, _ fn: @escaping (T) -> ()) {
        let listener = Listener<T>(fn)
        on(type, listener)
    }
    
    func once(_ type: String, _ fn: @escaping () -> ()) {
        let listener = Listener<Void>(fn, true)
        on(type, listener)
    }
    
    func once<T>(_ type: String, _ fn: @escaping (T) -> ()) {
        let listener = Listener<T>(fn, true)
        on(type, listener)
    }
    
    private func on<T>(_ type: String, _ listener: Listener<T>) {
        if listeners[type] == nil {
            listeners[type] = []
        }
        lock.with { listeners[type]?.append(listener) }
    }

    func removeAllListeners() {
        listeners = [:]
    }

    private func removeListener<T>(_ type: String, _ listener: Listener<T>?) {
        lock.with {
            if let listener = listener {
                listeners[type]?
                    .removeAll(where: { l in
                        (l as? Listener<T>) === listener
                    })
            } else {
                listeners.removeValue(forKey: type)
            }
        }
    }

}
