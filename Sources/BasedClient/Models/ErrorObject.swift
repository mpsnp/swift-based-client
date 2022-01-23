//
//  ErrorObject.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import AnyCodable

struct ErrorObject: Decodable {
    let type: String
    let message: String
    let name: String?
    let query:  [String: AnyDecodable]?
    let payload: AnyDecodable?
    let auth: Bool?
}

extension ErrorObject {
    init?(from data: AnyCodable) {
        if let data = data.value as? [String: Any],
            let type = data["type"] as? String,
            let message = data["message"] as? String {
            self.type = type
            self.message = message
            self.name = data["name"] as? String
            self.query = data["query"] as? [String : AnyDecodable]
            self.payload = data["payload"] as? AnyDecodable
            self.auth = data["auth"] as? Bool
        }
        return nil
    }
}
