//
//  Based+Delete.swift
//  
//
//  Created by Alexander van der Werff on 19/01/2022.
//

import Foundation


extension Based {
    
    public func delete(id: String, database: String? = nil) async throws -> Bool {
        var payloadObject = ["$id": id]
        if let database = database {
            payloadObject["db"] = database
        }
        let data = try await _delete(payload: JSON(payloadObject))
        let deleted = try decoder.decode([String: Int].self, from: data)
        let isDeleted = deleted["isDeleted"] ?? 0
        return isDeleted == 1 ? true : false
    }
    
    private func _delete(payload: JSON) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .delete, payload: payload, continuation: continuation, name: "")
        }
    }
    
}
