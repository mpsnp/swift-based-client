import XCTest
@testable import BasedClient

final class PatcherTests: XCTestCase {
    
    private var sut: Patcher!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = Patcher.default
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    
    func testObjectToArray() {
        let object = try! JSON(["0": 0, "1": 1, "2": 2, "3": 3])
        let patch = try! JSON([0, [0, 1, 2, 3, 4]])
        let patched: [Int] = sut.applyPatch(object, patch)!.asJsonArray(of: Int.self)
        XCTAssertEqual([0, 1, 2, 3, 4], patched)
    }
    
    
    func testArray() {
        let a: JSON = .from(string: """
            ["a", "b", "c", "d"]
        """)!

        let patch: JSON = .from(string: """
            [2,[7,[0,"x","x"],[1,2,0],[0,"z"],[1,2,2]]]
        """)!
        
        let patched: [String] = sut.applyPatch(a, patch)!.asJsonArray(of: String.self)
        XCTAssertEqual(["x", "x", "a", "b", "z", "c", "d"], patched)
    }
    
    
    func testArrayToObject() {
        let a: JSON = .from(string: """
            [0, 1, 2, 3, 4]
        """)!
                             
        let patch: JSON = .from(string: """
            {
                "4": [1],
                "___$toObject": true
            }
        """)!
        let expected = ["0": 0, "1": 1, "2": 2, "3": 3]
        let patched = sut.applyPatch(a, patch)?.asJsonObject as! [String: Int]
        XCTAssertEqual(expected, patched)
    }
    
    
    func testArrayToObjectNested() {
        let a: JSON = .from(string: """
            { "x": [ 0, 1, 2, 3, 4 ] }
        """)!
        
        let patch: JSON = .from(string: """
            { "x": { "0": [1], "4": [1], "flap": [ 0, 0 ], "___$toObject": true } }
        """
        )!

        let b: JSON = .from(string: """
              {
                "x": {
                  "flap": 0,
                  "1": 1,
                  "2": 2,
                  "3": 3
                }
              }
        """
        )!
        
        let patched = sut.applyPatch(a, patch)!
        XCTAssertTrue(b == patched, "\(b) != \(patched)")
    }
    
    
    func testWeirdArray() {
        let patch: JSON = .from(string: """
            {"upcoming":[2,[10,[1,1,8],[1,1,7],[1,1,4],[1,1,3],[1,1,2],[1,1,1],[1,1,0],[1,1,6],[1,1,5],[2,9,{"id":[0,"maug13"]}]]],"past":[2,[10,[1,1,9],[1,1,4],[1,1,3],[1,1,2],[1,1,1],[1,1,0],[1,1,8],[1,1,7],[1,1,6],[1,1,5]]],"live":[2,[1,[0,{"id":"mau1"}]]]}

        """
        )!

        let a: JSON = .from(string: """
            {
        "upcoming"    : [
        { "id": "maug8" },
        { "id": "maug7" },
        { "id": "maug5" },
        { "id": "maug4" },
        { "id": "maug2" },
        { "id": "maug11" },
        { "id": "maug10" },
        { "id": "maug1" },
        { "id": "mau2" },
        { "id": "mau1" }
        ],
        "past": [
        { "id": "map8" },
        { "id": "map7" },
        { "id": "map5" },
        { "id": "map4" },
        { "id": "map2" },
        { "id": "map14" },
        { "id": "map13" },
        { "id": "map11" },
        { "id": "map10" },
        { "id": "map1" }
        ],
        "live": []
        }
        """
    )!

        let b: JSON = .from(string: """
            {
            "upcoming": [
              { "id": "mau2" },
              { "id": "maug1" },
              { "id": "maug2" },
              { "id": "maug4" },
              { "id": "maug5" },
              { "id": "maug7" },
              { "id": "maug8" },
              { "id": "maug10" },
              { "id": "maug11" },
              { "id": "maug13" }
            ],
            "past": [
              { "id": "map1" },
              { "id": "map2" },
              { "id": "map4" },
              { "id": "map5" },
              { "id": "map7" },
              { "id": "map8" },
              { "id": "map10" },
              { "id": "map11" },
              { "id": "map13" },
              { "id": "map14" }
            ],
            "live": [{ "id": "mau1" }]
            }
        """
    )!
        
        let patched = sut.applyPatch(a, patch)!
        
        XCTAssertTrue(b == patched, "\(b) != \(patched)")
    }
    
    
    func testWeirdArray3RegisterCopy() {
        let patch: JSON = .from(string: """
             {"past":[2,[10,[2,0,{"id":[0,"mau1"]}],[1,9,0]]]}
         """
        )!
        
        let a: JSON = .from(string: """
            {
            "past": [
            { "id": "map1" },
            { "id": "map2" },
            { "id": "map4" },
            { "id": "map5" },
            { "id": "map7" },
            { "id": "map8" },
            { "id": "map10" },
            { "id": "map11" },
            { "id": "map13" },
            { "id": "map14" }
            ]
            }
         """
        )!

        let b: JSON = .from(string: """
            {
            "past": [
            { "id": "mau1" },
            { "id": "map1" },
            { "id": "map2" },
            { "id": "map4" },
            { "id": "map5" },
            { "id": "map7" },
            { "id": "map8" },
            { "id": "map10" },
            { "id": "map11" },
            { "id": "map13" }
            ]
            }
         """
        )!
        
        let patched = sut.applyPatch(a, patch)!
        
        XCTAssertTrue(b == patched, "\(b) != \(patched)")
     }
    
    
    func testArrayPlusNestedObject() {
        let a: JSON = .from(string: """
        {
        "a": "hello",
        "f": [
        {
        "x": true,
        "bla": {
        "flap": true
        }
        },
        {
        "x": true,
        "bla": {
        "flap": true
        }
        },
        {
        "y": true,
        "flurp": {
        "flurp": "x"
        }
        },
        {
        "z": true,
        "j": true
        }
        ]
        }
        """
        )!

        let b: JSON = .from(string: """
        {
        "f": [
        {
        "x": true,
        "bla": {
        "flap": true
        }
        },
        {
        "x": true,
        "bla": {
        "flap": true
        }
        },
        {
        "y": true,
        "flurp": {
        "flurp": {
        "flurpypants": [1, 2, 3]
        }
        }
        },
        {
        "z": true,
        "j": true
        },
        {
        "id": 10
        },
        {
        "id": 20
        }
        ]
        }
        """
        )!

        let patch: JSON = .from(string: """
            {"f":[2,[6,[1,2,0],[2,2,{"flurp":{"flurp":[0,{"flurpypants":[1,2,3]}]}}],[1,1,3],[0,{"id":10},{"id":20}]]],"a":[1]}
        """
        )!
        
        let patched = sut.applyPatch(a, patch)!
        
        XCTAssertTrue(b == patched, "\(b) != \(patched)")
    }
    
    
    func testArrayAndNestedObject() {
        let object: JSON = .from(string: """
             {"x":true,"y":true,"cnt":324,"kookiepants":{"x":true,"y":{"g":{"x":true,"flurpypants":"x","myText":"fdwefjwef ewofihewfoihwef weoifh"}}}}
         """
        )!
        
        var aObjects = [JSON]()
        var bObjects = [JSON]()
        
        for _ in 0..<20 {
            aObjects.append(object)
            bObjects.append(object)
        }
        
        bObjects[5] = JSON.object(["gurken": JSON.bool(true)])
        
        let a: JSON = ["f": JSON.array(aObjects)]
        var b: JSON = ["f": JSON.array(bObjects)]
        

        let patch: JSON = .from(string: #"{"f":[2,[20,[1,5,0],[2,5,{"gurken":[0,true],"x":[1],"y":[1],"cnt":[1],"kookiepants":[1]}],[1,14,6]]]}"#)!
        
        let patched = sut.applyPatch(a, patch)!
        
//        let diff = bObjects.difference(from: patched["f"]!.arrayValue!) { a, b in
//            a == b
//        }
        
        XCTAssertTrue(b == patched, "Not equal!")
        
        let patch2: JSON = JSON.from(string: #"{"f":[2,[20,[1,1,0],[2,1,{"flurb":[0,true],"x":[1],"y":[1],"cnt":[1],"kookiepants":[1]}],[1,1,2],[2,3,{"flura":[0,true],"x":[1],"y":[1],"cnt":[1],"kookiepants":[1]}],[1,4,4],[2,8,{"gurky":[0,true],"x":[1],"y":[1],"cnt":[1],"kookiepants":[1]}],[1,1,9],[2,10,{"kookiepants":{"x":[0,false],"y":{"g":{"myText":[0,"yuzi pants"],"x":[1],"flurpypants":[1]}}},"x":[1],"y":[1],"cnt":[1]}],[1,9,11]]]}"#
        )!

        bObjects[8] = JSON.object(["gurky": JSON.bool(true)])
        bObjects[1] = JSON.object(["flurb": JSON.bool(true)])
        bObjects[3] = JSON.object(["flura": JSON.bool(true)])
        let obj: JSON = .from(string: #"{"kookiepants": {"x": false,"y": {"g": {"myText": "yuzi pants"}}}}"#)!
        bObjects[10] = obj
        
        b = ["f": JSON.array(bObjects)]

        let patched2 = sut.applyPatch(patched, patch2)!
        
        XCTAssertTrue(patched2 == b, "Not equal!")
        
//        measure {
//            _ = sut.applyPatch(a, patch)
//        }
    }
    
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Dictionary {
    func toJSONString() -> String? {
        guard
            let jsonData = try? JSONSerialization.data(
               withJSONObject: self,
               options: [.withoutEscapingSlashes, .sortedKeys]
            ),
            let json = String(data: jsonData, encoding: .utf8)
        else { return nil }
        return json
    }
}
