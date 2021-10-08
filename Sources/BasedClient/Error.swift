//
//  Error.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

enum BasedError: Error {
    case
        generic,
        auth(_ token: String?)
}
