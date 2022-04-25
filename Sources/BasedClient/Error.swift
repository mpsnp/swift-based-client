//
//  Error.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

/*
 [\"message\": \"Unauthorized request\",
   \"type\": \"AuthorizationError\",
   \"auth\": true,
   \"payload\": [\"documents\": false, \"id\": \"use22bd860\"], \"name\": \"call \\\"users-observeId\\\"\"])]
 */

public enum BasedError: Error {
    case
        configuration(_ reason: String),
        validation(message: String?),
        authorization(message: String, name: String?),
        functionNotExist(message: String?),
        missingToken(message: String?),
        noValidURL(message: String?),
        other(message: String?)
}

extension BasedError {
    static func from(_ errorObject: ErrorObject) -> Self {
        switch errorObject.type {
        case "AuthorizationError":
            return .authorization(message: errorObject.message, name: errorObject.name)
        case "FunctionDoesNotExistError":
            return .functionNotExist(message: errorObject.message)
        default:
            return .other(message: errorObject.message)
        }
    }
}
