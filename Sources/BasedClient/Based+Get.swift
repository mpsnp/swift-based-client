//
//  Based+Get.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation

extension Based {
    
    public func get<T: Decodable>(query: Query) async throws -> T {
        let data = try await _get(query: query)
        return try decoder.decode(T.self, from: data)
    }
    
    private func _get(query: Query) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let payload = (try? JSON(query.dictionary())) ?? .null
            addRequest(type: .get, payload: payload, continuation: continuation, name: "")
        }
    }
    
}
