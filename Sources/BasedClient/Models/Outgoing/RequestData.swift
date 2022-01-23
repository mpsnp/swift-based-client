//
//  RequestData.swift
//  
//
//  Created by Alexander van der Werff on 19/12/2021.
//

import Foundation
import AnyCodable

struct RequestData {
    let requestType: RequestType
    let callbackId: Int
    let payload: [String: AnyCodable]
    let error: ErrorObject?
}
