//
//  Error.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

import AnyCodable

struct AuthorizationError {
    let name: String
    let call: String?
    let auth: Bool?
    let message: String?
    let payload: [String: Any]?
}

extension AuthorizationError {
    init?(_ json: [String: AnyCodable]) {
        guard let name = json["name"]?.value as? String else { return nil }
        self.name = name
        self.call = json["call"]?.value as? String
        self.auth = json["auth"]?.value as? Bool
        self.message = json["message"]?.value as? String
        self.payload = json["payload"]?.value as? [String: Any]
    }
}

public enum BasedError: Error {
    case
        generic,
        auth(_ token: String?),
        configuration(_ reason: String),
        other(_ message: String?),
        validation(_ message: String?)
    
    enum request: Error {
        case authorization(AuthorizationError?)
    }
}
