//
//  Environment.swift
//  BasicExample
//
//  Created by Alexander van der Werff on 11/02/2022.
//

import Foundation
import BasedClient

var Current = Environment()

struct Environment {
    var client: Client = .default
}
