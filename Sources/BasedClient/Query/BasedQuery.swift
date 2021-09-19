//
//  BasedQuery.swift
//  
//
//  Created by Alexander van der Werff on 19/09/2021.
//

import Foundation

public typealias QueryItem = BasedQuery.QueryItem
public typealias Query = BasedQuery

public enum BasedQuery {
    case query([QueryItem])
    public enum QueryItem {
        indirect case item(_ name: String, values: [String]? = nil, value: Bool? = nil, items: [QueryItem]? = nil)
        
        static func field(_ name: String, _ items: QueryItem...) -> Self {
            .item(name, items: items)
        }
        
        static func field(_ name: String, _ value: Bool) -> Self {
            .item(name, value: value)
        }
        
        static func field(_ name: String, _ values: String...) -> Self {
            .item(name, values: values)
        }
    }
}

public extension BasedQuery {
    static func query(_ values: QueryItem...) -> BasedQuery {
        .query(values)
    }
    
    func render() -> String {
        var jsonString = "{"
        switch self {
        case .query(let items):
            items.map(Self.render).joined(separator: ", ").forEach { jsonString.append($0) }
        }
        jsonString += "}"
        return jsonString
    }
    
    private static func render(_ item: QueryItem) -> String {
        var jsonString = ""
          switch item {
          case let .item(name, values, value, items):
            jsonString.append("\"\(name)\": ")
            if let values = values {
                if values.count > 1 {
                    jsonString.append(values.jsonStringify())
                } else {
                    jsonString.append("\"\(values[0])\"")
                }
            } else if let value = value {
                jsonString.append("\(value)")
            }
            if let items = items {
                jsonString.append("{")
                items.map(render).joined(separator: ", ").forEach { jsonString.append($0) }
                jsonString.append("}")
            }
          }
        return jsonString
    }
}
