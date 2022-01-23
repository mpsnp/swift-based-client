import XCTest
@testable import BasedClient

final class BasedQueryTests: XCTestCase {
    
    let query = BasedQuery
        .query(
            .id("root"),
            .field("id", true),
            .field("items",
                   .field("name", true),
                   .field("nonense", .default("yes")),
                   .list(
                    .find(
                        .recursive(true),
                        .traverse(
                            .field("root", "children"),
                            .field("league", .first("matches", "children")),
                            .field("team", .all("parents", "children")),
                            .any(true)
                        )
                    )
                   )
                )
            )
    
    func testQueryRender() {
      XCTAssertEqual(
        #"""
        {"$id": "root", "id": true, "items": {"name": true, "nonense": {"$default": "yes"}, "$list": {"$find": {"$recursive": true, "$traverse": {"root": "children", "league": {"$first": ["matches", "children"]}, "team": {"$all": ["parents", "children"]}, "$any": true}}}}}
        """#,
        query.jsonStringify()
      )
    }
    
}
