//
//  ErrorObject.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import AnyCodable


/// ErrorObject returned from Based server
/// Example:
/// [
///     "message": "Unauthorized request",
///     "type": "AuthorizationError",
///     "auth": true,
///     "payload": ["documents": false, "id": "use22bd860"],
///     "name": "call users-observeId"])
/// ]
struct ErrorObject: Decodable {
    let type: String
    let message: String
    let name: String?
    let query: AnyDecodable?
    let payload: AnyDecodable?
    let auth: Bool?
    let code: String?
}


extension ErrorObject {
    init?(from data: AnyCodable) {
        guard let data = data.value as? [String: Any] else {
            return nil
        }
        type = data["type"] as? String ?? ""
        message = data["message"] as? String ?? ""
        name = data["name"] as? String
        query = AnyDecodable(data["query"])
        payload = AnyDecodable(data["payload"])
        auth = data["auth"] as? Bool
        code = data["code"] as? String
    }
}
