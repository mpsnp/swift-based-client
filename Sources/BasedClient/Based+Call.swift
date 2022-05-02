//
//  Based+Call.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import AnyCodable

public struct FunctionSignature<Arg: Encodable, Res: Decodable> {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

extension Based {
    public func call<Arg: Encodable, Res: Decodable>(_ function: FunctionSignature<Arg, Res>, arg: Arg) async throws -> Res {
        let encoder = SafeJSONEncoder()
        let payload = try encoder.encode(arg)
        
        return try await call(name: function.name, payload: payload)
    }
    
    public func call<T: Decodable>(name: String, payload: JSON = [:]) async throws -> T {
        let data = try await _call(name: name, payload: payload)
        return try decoder.decode(T.self, from: data)
    }
    
    private func _call(name: String, payload: JSON) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .call, payload: payload, continuation: continuation, name: name)
        }
    }
    
}
