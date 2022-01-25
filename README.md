# Based Swift client

This is a port of https://github.com/atelier-saulx/based-core/tree/main/docs, an Ios client for the Based data platform.
=======
# Usage

## Config
```
let client = Based(config: BasedConfig(env: "env", project: "projectName", org: "organization"))
```
## Get
```
let res: Root = try await client.get(query: BasedQuery.query(.field("children", .field("name", true), .field("id", true),.list(true))))
```
## Delete
```
let res = try await client.delete(id: "root")
```
## Set
```
let res = try await client.set(query: BasedQuery.query(.field("type", "thing"), .field("name", name)))
```
## Observe
```
let publisher: Based.DataPublisher<SomeType> = client.publisher(name: "some-func-name", payload: [:])
cancellable = publisher.receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
    print("Received completion: \(completion)")
}, receiveValue: { value in
    print(values)
})
```
