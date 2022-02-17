//
//  Based+Schema.swift
//  
//
//  Created by Alexander van der Werff on 13/02/2022.
//

import Foundation
import AnyCodable

extension Based {
    
    public func schema() async throws -> Any {
        let data = try await _schema()
        let schema = try decoder.decode(AnyDecodable.self, from: data)
        return schema.value
    }
    
    private func _schema() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .getConfiguration, payload: JSON.number(0), continuation: continuation, name: "")
        }
    }
    
    public func configure(schema: [String: Any]) async throws -> Any {
        let data = try await _configure(payload: JSON(["schema": schema]))
        let schema = try decoder.decode(AnyDecodable.self, from: data)
        return schema.value
    }
    
    private func _configure(payload: JSON) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .configuration, payload: payload, continuation: continuation, name: "")
        }
    }
    
}
