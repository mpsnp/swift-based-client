//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 19/09/2021.
//

import Foundation

/**
    Based query language operators
 */

extension BasedQuery.QueryItem {
    
    public static func id(_ values: String...) -> Self {
        .item("$id", values: values)
    }
    
    public static func alias(_ values: String...) -> Self {
        .item("$alias", values: values)
    }
    
    public static func `default`(_ values: String...) -> Self {
        .item("$default", values: values)
    }
    
    public static func type(_ values: String...) -> Self {
        .item("$type", values: values)
    }
    
    public static func all(_ value: Bool) -> Self {
        .item("$all", value: value)
    }
    
    public static func all(_ values: String...) -> Self {
        .item("$all", values: values)
    }
    
    public static func inherit(_ value: Bool) -> Self {
        .item("$inherit", value: value)
    }
    
    public static func language(_ value: String) -> Self {
        .item("$language", values: [value])
    }
    
    public static func required(_ values: String...) -> Self {
        .item("$required", values: values)
    }

    public static func traverse(_ value: Bool) -> Self {
        .item("$traverse", value: value)
    }
    
    public static func traverse(_ values: String...) -> Self {
        .item("$traverse", values: values)
    }
    
    public static func traverse(_ items: QueryItem...) -> Self {
        .item("$traverse", items: items)
    }

    public static func first(_ values: String...) -> Self {
        .item("$first", values: values)
    }
    
    public static func any(_ value: Bool) -> Self {
        .item("$any", value: value)
    }
    
    public static func list(_ value: Bool) -> Self {
        .item("$list", value: value)
    }
    
    public static func recursive(_ value: Bool) -> Self {
        .item("$recursive", value: value)
    }

    public static func list(_ items: QueryItem...) -> Self {
        .item("$list", items: items)
    }
    
    public static func find(_ items: QueryItem...) -> Self {
        .item("$find", items: items)
    }
    
    public static func from(_ values: String...) -> Self {
        .item("$field", values: values)
    }
    
    public static func db(_ value: String) -> Self {
        .item("$db", values: [value])
    }
    
    public static func merge(_ value: Bool) -> Self {
        .item("$merge", value: value)
    }
    
    public enum SetOperation: String {
        case upsert, insert, update
    }
    
    public static func operation(_ value: SetOperation) -> Self {
        .item("$operation", values: ["\(value)"])
    }
    
    public static func aliases(_ values: String...) -> Self {
        .item("aliases", values: values)
    }
    
    public static func delete() -> Self {
        .item("$delete", value: true)
    }

    public static func delete(_ items: QueryItem...) -> Self {
        .item("$delete", items: items)
    }
    
    public static func add(_ values: String...) -> Self {
        .item("$add", values: values)
    }
    
}
