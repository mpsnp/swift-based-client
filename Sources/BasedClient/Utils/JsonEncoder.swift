import Foundation

private protocol JSONStringDictionaryEncodableMarker { }

extension Dictionary: JSONStringDictionaryEncodableMarker where Key == String, Value: Encodable { }

public final class SafeJSONEncoder {
    
    public init() {}
    
    public func encode<Value: Encodable>(_ value: Value) throws -> JSON {
        let encoder = JSONEncoderImpl(codingPath: [])
        guard let topLevel = try encoder.wrapEncodable(value, for: nil) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(Value.self) did not encode any values."))
        }
        
        return topLevel
    }
}


private final class JSONEncoderImpl: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] = [:]
    
    var singleValue: JSON?
    var array: JSONFuture.RefArray?
    var object: JSONFuture.RefObject?
    
    var value: JSON? {
        if let object = self.object {
            return .object(object.values)
        }
        if let array = self.array {
            return .array(array.values)
        }
        return self.singleValue
    }
    
    init(codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        guard self.object == nil, self.array == nil else {
            preconditionFailure()
        }
        
        return JSONSingleValueEncodingContainer(impl: self, codingPath: self.codingPath)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if let _ = array {
            return JSONUnkeyedEncodingContainer(impl: self, codingPath: self.codingPath)
        }

        guard self.singleValue == nil, self.object == nil else {
            preconditionFailure()
        }

        self.array = JSONFuture.RefArray()
        return JSONUnkeyedEncodingContainer(impl: self, codingPath: self.codingPath)
    }
    
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        if let _ = object {
            let container = JSONKeyedEncodingContainer<Key>(impl: self, codingPath: codingPath)
            return KeyedEncodingContainer(container)
        }

        guard self.singleValue == nil, self.array == nil else {
            preconditionFailure()
        }

        self.object = JSONFuture.RefObject()
        let container = JSONKeyedEncodingContainer<Key>(impl: self, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }
}

extension JSONEncoderImpl: SpecialTreatmentEncoder {
    var impl: JSONEncoderImpl {
        return self
    }

    // untyped escape hatch. needed for `wrapObject`
    func wrapUntyped(_ encodable: Encodable) throws -> JSON {
        switch encodable {
        case let date as Date:
            return try self.wrapDate(date, for: nil)
        case let data as Data:
            return try self.wrapData(data, for: nil)
        case let url as URL:
            return .string(url.absoluteString)
        case let object as [String: Encodable]: // this emits a warning, but it works perfectly
            return try self.wrapObject(object, for: nil)
        default:
            try encodable.encode(to: self)
            return self.value ?? .object([:])
        }
    }
}

internal struct _JSONKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    internal init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    internal static let `super` = _JSONKey(stringValue: "super")!
}

private struct JSONKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol, SpecialTreatmentEncoder {
    let impl: JSONEncoderImpl
    let object: JSONFuture.RefObject
    let codingPath: [CodingKey]

    private var firstValueWritten: Bool = false
    
    init(impl: JSONEncoderImpl, codingPath: [CodingKey]) {
        self.impl = impl
        self.object = impl.object!
        self.codingPath = codingPath
    }

    // used for nested containers
    init(impl: JSONEncoderImpl, object: JSONFuture.RefObject, codingPath: [CodingKey]) {
        self.impl = impl
        self.object = object
        self.codingPath = codingPath
    }

    private func _converted(_ key: Key) -> CodingKey {
        return key
    }

    mutating func encodeNil(forKey key: Self.Key) throws {
        self.object.set(.null, for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        self.object.set(.bool(value), for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        self.object.set(.string(value), for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        self.object.set(.double(value), for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        self.object.set(.double(Double(value)), for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        let convertedKey = self._converted(key)
        let encoded = try self.wrapEncodable(value, for: convertedKey)
        self.object.set(encoded ?? .object([:]), for: convertedKey.stringValue)
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) ->
        KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
        let convertedKey = self._converted(key)
        let newPath = self.codingPath + [convertedKey]
        let object = self.object.setObject(for: convertedKey.stringValue)
        let nestedContainer = JSONKeyedEncodingContainer<NestedKey>(impl: impl, object: object, codingPath: newPath)
        return KeyedEncodingContainer(nestedContainer)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let convertedKey = self._converted(key)
        let newPath = self.codingPath + [convertedKey]
        let array = self.object.setArray(for: convertedKey.stringValue)
        let nestedContainer = JSONUnkeyedEncodingContainer(impl: impl, array: array, codingPath: newPath)
        return nestedContainer
    }

    mutating func superEncoder() -> Encoder {
        let newEncoder = self.getEncoder(for: _JSONKey.super)
        self.object.set(newEncoder, for: _JSONKey.super.stringValue)
        return newEncoder
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        let convertedKey = self._converted(key)
        let newEncoder = self.getEncoder(for: convertedKey)
        self.object.set(newEncoder, for: convertedKey.stringValue)
        return newEncoder
    }
}

extension JSONKeyedEncodingContainer {
    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N, key: CodingKey) throws {
        self.object.set(.int(Int(value)), for: key.stringValue)
    }
}

private struct JSONUnkeyedEncodingContainer: UnkeyedEncodingContainer, SpecialTreatmentEncoder {
    let impl: JSONEncoderImpl
    let array: JSONFuture.RefArray
    let codingPath: [CodingKey]

    var count: Int {
        self.array.array.count
    }
    private var firstValueWritten: Bool = false
    
    init(impl: JSONEncoderImpl, codingPath: [CodingKey]) {
        self.impl = impl
        self.array = impl.array!
        self.codingPath = codingPath
    }

    // used for nested containers
    init(impl: JSONEncoderImpl, array: JSONFuture.RefArray, codingPath: [CodingKey]) {
        self.impl = impl
        self.array = array
        self.codingPath = codingPath
    }

    mutating func encodeNil() throws {
        self.array.append(.null)
    }

    mutating func encode(_ value: Bool) throws {
        self.array.append(.bool(value))
    }

    mutating func encode(_ value: String) throws {
        self.array.append(.string(value))
    }

    mutating func encode(_ value: Double) throws {
        self.array.append(.double(value))
    }

    mutating func encode(_ value: Float) throws {
        self.array.append(.double(Double(value)))
    }

    mutating func encode(_ value: Int) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int64) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt64) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        let key = _JSONKey(stringValue: "Index \(self.count)", intValue: self.count)
        let encoded = try self.wrapEncodable(value, for: key)
        self.array.append(encoded ?? .object([:]))
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) ->
        KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
        let newPath = self.codingPath + [_JSONKey(index: self.count)]
        let object = self.array.appendObject()
        let nestedContainer = JSONKeyedEncodingContainer<NestedKey>(impl: impl, object: object, codingPath: newPath)
        return KeyedEncodingContainer(nestedContainer)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let newPath = self.codingPath + [_JSONKey(index: self.count)]
        let array = self.array.appendArray()
        let nestedContainer = JSONUnkeyedEncodingContainer(impl: impl, array: array, codingPath: newPath)
        return nestedContainer
    }

    mutating func superEncoder() -> Encoder {
        let encoder = self.getEncoder(for: _JSONKey(index: self.count))
        self.array.append(encoder)
        return encoder
    }
    
    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N) throws {
        self.array.append(.int(Int(value)))
    }
}

private struct JSONSingleValueEncodingContainer: SingleValueEncodingContainer, SpecialTreatmentEncoder {
    let impl: JSONEncoderImpl
    let codingPath: [CodingKey]

    private var firstValueWritten: Bool = false
    
    init(impl: JSONEncoderImpl, codingPath: [CodingKey]) {
        self.impl = impl
        self.codingPath = codingPath
    }

    mutating func encodeNil() throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = .null
    }

    mutating func encode(_ value: Bool) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = .bool(value)
    }

    mutating func encode(_ value: Int) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int64) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt64) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Float) throws {
        self.impl.singleValue = .double(Double(value))
    }

    mutating func encode(_ value: Double) throws {
        self.impl.singleValue = .double(value)
    }

    mutating func encode(_ value: String) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = .string(value)
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = try self.wrapEncodable(value, for: nil)
    }

    func preconditionCanEncodeNewValue() {
        precondition(self.impl.singleValue == nil, "Attempt to encode value through single value container when previously value already encoded.")
    }
    
    @inline(__always) private mutating func encodeFixedWidthInteger<N: FixedWidthInteger>(_ value: N) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = .int(Int(value))
    }
}

private protocol SpecialTreatmentEncoder {
    var codingPath: [CodingKey] { get }
    var impl: JSONEncoderImpl { get }
}

extension SpecialTreatmentEncoder {
    fileprivate func wrapEncodable<E: Encodable>(_ encodable: E, for additionalKey: CodingKey?) throws -> JSON? {
        switch encodable {
        case let date as Date:
            return try self.wrapDate(date, for: additionalKey)
        case let data as Data:
            return try self.wrapData(data, for: additionalKey)
        case let url as URL:
            return .string(url.absoluteString)
        case let object as JSONStringDictionaryEncodableMarker:
            return try self.wrapObject(object as! [String: Encodable], for: additionalKey)
        default:
            let encoder = self.getEncoder(for: additionalKey)
            try encodable.encode(to: encoder)
            return encoder.value
        }
    }

    func wrapDate(_ date: Date, for additionalKey: CodingKey?) throws -> JSON {
        let encoder = self.getEncoder(for: additionalKey)
        try date.encode(to: encoder)
        return encoder.value ?? .null
    }

    func wrapData(_ data: Data, for additionalKey: CodingKey?) throws -> JSON {
        let encoder = self.getEncoder(for: additionalKey)
        try data.encode(to: encoder)
        return encoder.value ?? .null
    }

    func wrapObject(_ object: [String: Encodable], for additionalKey: CodingKey?) throws -> JSON {
        var baseCodingPath = self.codingPath
        if let additionalKey = additionalKey {
            baseCodingPath.append(additionalKey)
        }
        var result = [String: JSON]()
        result.reserveCapacity(object.count)

        try object.forEach { (key, value) in
            var elemCodingPath = baseCodingPath
            elemCodingPath.append(_JSONKey(stringValue: key, intValue: nil))
            let encoder = JSONEncoderImpl(codingPath: elemCodingPath)

            result[key] = try encoder.wrapUntyped(value)
        }

        return .object(result)
    }

    fileprivate func getEncoder(for additionalKey: CodingKey?) -> JSONEncoderImpl {
        if let additionalKey = additionalKey {
            var newCodingPath = self.codingPath
            newCodingPath.append(additionalKey)
            return JSONEncoderImpl(codingPath: newCodingPath)
        }

        return self.impl
    }
}


private enum JSONFuture {
    case value(JSON)
    case encoder(JSONEncoderImpl)
    case nestedArray(RefArray)
    case nestedObject(RefObject)
    
    final class RefArray {
        private(set) var array: [JSONFuture] = []

        init() {
            self.array.reserveCapacity(10)
        }

        @inline(__always) func append(_ element: JSON) {
            self.array.append(.value(element))
        }

        @inline(__always) func append(_ encoder: JSONEncoderImpl) {
            self.array.append(.encoder(encoder))
        }

        @inline(__always) func appendArray() -> RefArray {
            let array = RefArray()
            self.array.append(.nestedArray(array))
            return array
        }

        @inline(__always) func appendObject() -> RefObject {
            let object = RefObject()
            self.array.append(.nestedObject(object))
            return object
        }

        var values: [JSON] {
            self.array.map { future -> JSON in
                switch future {
                case .value(let value):
                    return value
                case .nestedArray(let array):
                    return .array(array.values)
                case .nestedObject(let object):
                    return .object(object.values)
                case .encoder(let encoder):
                    return encoder.value ?? .object([:])
                }
            }
        }
    }
    
    final class RefObject {
        private(set) var dict: [String: JSONFuture] = [:]
        
        init() {
            self.dict.reserveCapacity(20)
        }
        
        @inline(__always) func set(_ value: JSON, for key: String) {
            self.dict[key] = .value(value)
        }
        
        @inline(__always) func setArray(for key: String) -> RefArray {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedObject:
                preconditionFailure("For key \"\(key)\" a keyed container has already been created.")
            case .nestedArray(let array):
                return array
            case .none, .value:
                let array = RefArray()
                dict[key] = .nestedArray(array)
                return array
            }
        }
        
        @inline(__always) func setObject(for key: String) -> RefObject {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedObject(let object):
                return object
            case .nestedArray:
                preconditionFailure("For key \"\(key)\" a unkeyed container has already been created.")
            case .none, .value:
                let object = RefObject()
                dict[key] = .nestedObject(object)
                return object
            }
        }
        
        @inline(__always) func set(_ encoder: JSONEncoderImpl, for key: String) {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedObject:
                preconditionFailure("For key \"\(key)\" a keyed container has already been created.")
            case .nestedArray:
                preconditionFailure("For key \"\(key)\" a unkeyed container has already been created.")
            case .none, .value:
                dict[key] = .encoder(encoder)
            }
        }
        
        var values: [String: JSON] {
            self.dict.mapValues { future -> JSON in
                switch future {
                case .value(let value):
                    return value
                case .nestedArray(let array):
                    return .array(array.values)
                case .nestedObject(let object):
                    return .object(object.values)
                case .encoder(let encoder):
                    return encoder.value ?? .object([:])
                }
            }
        }
    }
}
