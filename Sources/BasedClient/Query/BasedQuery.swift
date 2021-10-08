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
    
    func jsonStringify() -> String {
        var jsonString = "{"
        switch self {
        case .query(let items):
            items.map(Self.jsonStringify).joined(separator: ", ").forEach { jsonString.append($0) }
        }
        jsonString += "}"
        return jsonString
    }
    
    private static func jsonStringify(_ item: QueryItem) -> String {
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
                items.map(jsonStringify).joined(separator: ", ").forEach { jsonString.append($0) }
                jsonString.append("}")
            }
          }
        return jsonString
    }
    
    func dictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        switch self {
        case .query(let items):
            for qItem in items {
                let result = Self.dictionary(qItem)
                result.keys.forEach {
                    dictionary[$0] = result[$0]
                }
            }
        }
        return dictionary
    }
    
    private static func dictionary(_ item: QueryItem) -> [String: Any] {
        var dictionary = [String: Any]()
        switch item {
          case let .item(name, values, value, items):
            if let values = values {
                if values.count > 1 {
                    dictionary[name] = values
                } else {
                    dictionary[name] = values[0]
                }
            } else if let value = value {
                dictionary[name] = value
            }
            if let items = items {
                var result = [[String: Any]]()
                for qItem in items {
                    result.append(Self.dictionary(qItem))
                }
                let flattenedDictionary = result
                    .flatMap { $0 }
                    .reduce([String: Any]()) { (dict, tuple) in
                        var dict = dict
                        dict.updateValue(tuple.1, forKey: tuple.0)
                        return dict
                    }
                dictionary[name] = flattenedDictionary
            }
          }
        return dictionary
    }
}
