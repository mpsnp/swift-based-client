import Foundation

/// Typesafe Json implementation, suitable in all places where you want to enforce compile-time check of data structure
///
/// - Warning: Use it only if Codable don't suite your needs
public enum JSON: Equatable, Hashable {
    case null
    
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    
    case array([JSON])
    case object([String: JSON])
}

// MARK: - Properties

extension JSON {
    /// Is true if is null
    public var isNull: Bool {
        .null == self
    }
    
    /// Extracts int from json, or overwrites it with int value
    public var intValue: Int? {
        get { if case let .int(value) = self { return value } else { return nil } }
        set { self = newValue.map(JSON.int) ?? .null }
    }
    
    /// Extracts double from json, or overwrites it with double value
    public var doubleValue: Double? {
        get { if case let .double(value) = self { return value } else { return nil } }
        set { self = newValue.map(JSON.double) ?? .null }
    }
    
    /// Extracts bool from json, or overwrites it with bool value
    public var boolValue: Bool? {
        get { if case let .bool(value) = self { return value } else { return nil } }
        set { self = newValue.map(JSON.bool) ?? .null }
    }
    
    /// Extracts string from json, or overwrites it with string value
    public var stringValue: String? {
        get { if case let .string(value) = self { return value } else { return nil } }
        set { self = newValue.map(JSON.string) ?? .null }
    }
    
    /// Extracts array from json, or overwrites it with new value
    public var arrayValue: [JSON]? {
        get { if case let .array(value) = self { return value } else { return nil } }
        set { self = newValue.map(JSON.array) ?? .null }
    }
    
    /// Extracts object from json, or overwrites it with new value
    public var objectValue: [String: JSON]? {
        get { if case let .object(value) = self { return value } else { return nil } }
        set { self = newValue.map(JSON.object) ?? .null }
    }
    
    /// If json is array, extracts value by index, as well as allows to overwrite value in array
    public subscript(_ index: Int) -> JSON? {
        get { if case let .array(value) = self { return value[index] } else { return nil } }
        set {
            guard case var .array(array) = self else { return }
            array[index] = newValue ?? .null
            self = .array(array)
        }
    }
    
    /// If json is object, extracts value by key, as well as allows to overwrite value in object
    public subscript(_ key: String) -> JSON? {
        get { if case let .object(value) = self, let element = value[key] { return element } else { return nil } }
        set {
            guard case var .object(dictionary) = self else { return }
            dictionary[key] = newValue ?? .null
            self = .object(dictionary)
        }
    }
}

// MARK: - String representation

extension JSON {
    public enum JSONError: Swift.Error {
        case serializationFailed(EncodingError)
        case stringificationFailed
        case failedToParse
    }
    
    /// Allows to serialize json to raw data using provided encoder
    /// - Parameter encoder: encoder to be used for serialization. Allows to serialize to all json-compatible text formats, such as yaml, toml, xml, etc. Just provide correct encoder.
    /// - Returns: serialized data
    public func toData(with encoder: JSONEncoder = .init()) throws -> Data {
        return try encoder.encode(self)
    }
    
    /// Allows to serialize json to string using provided encoder
    /// - Parameter encoder: encoder to be used for serialization. Allows to jerialize to all json-compatible text formats, such as yaml, toml, xml, etc. Just provide correct encoder.
    /// - Returns: serialized json string
    public func toString(with encoder: JSONEncoder = .init()) throws -> String {
        let resultData: Data
        
        do {
            resultData = try toData(with: encoder)
        } catch let error as EncodingError {
            throw JSONError.serializationFailed(error)
        }
        
        guard let stringData = String(data: resultData, encoding: .utf8) else {
            throw JSONError.stringificationFailed
        }
        
        return stringData
    }
}

extension JSON: CustomStringConvertible {
    /// Serialized json value
    public var description: String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try self.toString(with: encoder)
        } catch {
            return String(describing: error)
        }
    }
}

// MARK: - Conversion from/to unsafe

extension JSON {
    /// Allows to create typesafe json from any data structure
    /// - Parameter jsonObject: object that's possibly a valid json
    public init(_ jsonValue: Any) throws {
        switch jsonValue {
        case is NSNull:
            self = .null
        case let value as Int:
            self = .int(value)
        case let value as Double:
            self = .double(value)
        case let value as Bool:
            self = .bool(value)
        case let value as String:
            self = .string(value)
        case let value as [Any]:
            self = try .array(value.map { try JSON($0) })
        case let value as [String: Any]:
            self = try .object(value.mapValues { try JSON($0) })
        default:
            throw JSONError.failedToParse
        }
    }
    
    /// Unsafe json object (objective c compatible)
    public var asJsonValue: Any {
        switch self {
        case .null:
            return NSNull()
        case let .int(value):
            return value
        case let .double(value):
            return value
        case let .bool(value):
            return value
        case let .string(value):
            return value
        case let .array(array):
            return array.map(\.asJsonValue)
        case let .object(dictionary):
            return dictionary.mapValues(\.asJsonValue)
        }
    }
    
    public var asJsonObject: [String: Any] {
        guard let result = asJsonValue as? [String: Any] else {
            fatalError("Json value is not an object")
        }
        return result
    }
    
    public var asJsonArray: [Any] {
        guard let result = asJsonValue as? [Any] else {
            fatalError("Json value is not an array")
        }
        return result
    }
    
    public func asJsonArray<Content>(of contentType: Content.Type) -> [Content] {
        guard let result = asJsonValue as? [Content] else {
            fatalError("Json value is not an array of type \([Content].self)")
        }
        return result
    }
}

// MARK: - Codable

extension JSON: Codable {
    // Conformance to Codable is not as efficient as for struct DTOs, but it's enough for small use cases.
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .null:
            try container.encodeNil()
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        case let .array(array):
            try container.encode(array)
        case let .object(object):
            try container.encode(object)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let object = try? container.decode([String: JSON].self) {
            self = .object(object)
        } else if let array = try? container.decode([JSON].self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Failed to decode any of supported json values",
                underlyingError: nil
            ))
        }
    }
}

// MARK: - Literal conformances

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self = .object(.init(uniqueKeysWithValues: elements))
    }
}
