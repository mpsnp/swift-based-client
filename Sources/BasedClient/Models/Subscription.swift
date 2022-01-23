//
//  Subscription.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

struct SubscriptionModel {
    var error: BasedError?
    var cnt: Int
    var payload: JSON?
    let name: String?
    var subscribers: Dictionary<SubscriberId, SubscriptionCallback> = [:]
}

struct SubscriptionCallback {
    var onInitial: InitialCallback?
    var onError: ErrorCallback?
    var onData: DataCallback?
}

enum SubscriptionType {
    case query(Query), `func`(_ name: String, _ payload: Any?)
    
    func generateSubscriptionId() -> Int {
        switch self {
        case .query(let query):
            if let json = try? JSON(query.dictionary()) {
                return Current.hasher.hashObjectIgnoreKeyOrder(json)
            }
        case let .func(name, payload):
            if let payload = payload, let json = try? JSON(payload) {
                return Current.hasher.hashObjectIgnoreKeyOrder(JSON.array([JSON.string(name), json]))
            }
        }
        return 0
    }
}
