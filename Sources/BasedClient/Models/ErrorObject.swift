//
//  ErrorObject.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation

struct ErrorObject {
    let type: String
    let message: String
    let name: String?
    let query: JSON?
    let payload: JSON?
    let auth: Bool?
}
