//
//  Based+Call.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import NakedJson

extension Based {
    
    public func call<T: Decodable>(name: String, payload: Json = [:]) async throws -> T {
        let data = try await _call(name: name, payload: payload)
        return try decoder.decode(T.self, from: data)
    }
    
    private func _call(name: String, payload: Json) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .call, payload: payload, continuation: continuation, name: name)
        }
    }
    
}
