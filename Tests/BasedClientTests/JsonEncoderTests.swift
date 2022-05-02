//
//  File.swift
//  
//
//  Created by gnkiriy on 03.05.2022.
//

import Foundation
import BasedClient
import XCTest

final class JsonEncoderTest: XCTestCase {
    func testSimple() throws {
        struct User: Encodable {
            let id: Int
            let name: String
        }
        
        let user = User(id: 5, name: "Blob")
        let userJson: JSON = [
            "id": 5,
            "name": "Blob"
        ]
        
        let encoder = SafeJSONEncoder()
        let encodedUserJson = try encoder.encode(user)
        
        XCTAssertEqual(encodedUserJson, userJson)
    }
    
    func testSimpleKeys() throws {
        struct User: Encodable {
            let id: Int
            let firstName: String
        }
        
        let user = User(id: 5, firstName: "Blob")
        let userJson: JSON = [
            "id": 5,
            "firstName": "Blob"
        ]
        
        let encoder = SafeJSONEncoder()
        let encodedUserJson = try encoder.encode(user)
        
        XCTAssertEqual(encodedUserJson, userJson)
    }
    
    func testArrayOfUsers() throws {
        struct User: Encodable {
            let id: Int
            let firstName: String
        }
        
        let users = [
            User(id: 5, firstName: "Blob"),
            User(id: 6, firstName: "Blob Jr"),
        ]
        let usersJson: JSON = [
            [
                "id": 5,
                "firstName": "Blob"
            ],
            [
                "id": 6,
                "firstName": "Blob Jr"
            ],
        ]
        
        let encoder = SafeJSONEncoder()
        let encodedUsersJson = try encoder.encode(users)
        
        XCTAssertEqual(encodedUsersJson, usersJson)
    }
    
    func testArrayOfIdentifiedUsers() throws {
        struct User: Encodable {
            struct ID: RawRepresentable, Encodable {
                var rawValue: Int
            }
            let id: ID
            let firstName: String
        }
        
        let users = [
            User(id: .init(rawValue: 5), firstName: "Blob"),
            User(id: .init(rawValue: 6), firstName: "Blob Jr"),
        ]
        let usersJson: JSON = [
            [
                "id": 5,
                "firstName": "Blob"
            ],
            [
                "id": 6,
                "firstName": "Blob Jr"
            ],
        ]
        
        let encoder = SafeJSONEncoder()
        let encodedUsersJson = try encoder.encode(users)
        
        XCTAssertEqual(encodedUsersJson, usersJson)
    }
}
