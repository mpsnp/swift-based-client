//
//  Array+String.swift
//  
//
//  Created by Alexander van der Werff on 19/09/2021.
//

import Foundation

extension Array where Element == String {
    func jsonStringify() -> String {
        "[" + map { "\"\($0)\"" }.joined(separator: ", ") + "]"
    }
}
