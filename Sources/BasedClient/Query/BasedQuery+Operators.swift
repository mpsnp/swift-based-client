//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 19/09/2021.
//

import Foundation

extension BasedQuery.QueryItem {
    
    static func id(_ values: String...) -> Self {
        .item("$id", values: values)
    }
    
    static func alias(_ values: String...) -> Self {
        .item("$alias", values: values)
    }
    
    static func `default`(_ values: String...) -> Self {
        .item("$default", values: values)
    }
    
    static func type(_ values: String...) -> Self {
        .item("$type", values: values)
    }
    
    static func all(_ value: Bool) -> Self {
        .item("$all", value: value)
    }
    
    static func all(_ values: String...) -> Self {
        .item("$all", values: values)
    }
    
    static func inherit(_ value: Bool) -> Self {
        .item("$inherit", value: value)
    }
    
    static func language(_ value: String) -> Self {
        .item("$language", values: [value])
    }
    
    static func required(_ values: String...) -> Self {
        .item("$required", values: values)
    }

    static func traverse(_ value: Bool) -> Self {
        .item("$traverse", value: value)
    }
    
    static func traverse(_ values: String...) -> Self {
        .item("$traverse", values: values)
    }
    
    static func traverse(_ items: QueryItem...) -> Self {
        .item("$traverse", items: items)
    }

    static func first(_ values: String...) -> Self {
        .item("$first", values: values)
    }
    
    static func any(_ value: Bool) -> Self {
        .item("$any", value: value)
    }
    
    static func list(_ value: Bool) -> Self {
        .item("$list", value: value)
    }
    
    static func recursive(_ value: Bool) -> Self {
        .item("$recursive", value: value)
    }

    static func list(_ items: QueryItem...) -> Self {
        .item("$list", items: items)
    }
    
    static func find(_ items: QueryItem...) -> Self {
        .item("$find", items: items)
    }
    
    static func from(_ values: String...) -> Self {
        .item("$field", values: values)
    }
    
}
