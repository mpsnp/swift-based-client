import AnyCodable
import Foundation

protocol Message {
    var subscriptionId: String { get }
    var codable: [AnyCodable] { get }
}

struct SomeMessage: Message {
    var subscriptionId: String
    var checksum: UInt64?
    var data: [String: Any]?
    var codable: [AnyCodable] {
        
        [AnyCodable(subscriptionId), AnyCodable(checksum), AnyCodable(data)]
    }
}

let m1 = SomeMessage(subscriptionId: "id1", checksum: 2)
let m2 = SomeMessage(subscriptionId: "id2", checksum: nil, data: ["a":["b":[1,2]]])

let array: [[AnyCodable]] = [m1.codable, m2.codable]

let encoder = JSONEncoder()
let json = try! encoder.encode(array)


let jsonString = String(data: json,
                        encoding: .utf8)
print(jsonString!)

