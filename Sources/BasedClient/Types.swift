//
//  Types.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//


public typealias DataCallback = (_ data: Any, _ checksum: Int) -> ()
public typealias ErrorCallback = (_ error: BasedError) -> ()
public typealias InitialCallback = (
    _ error: BasedError,
    _ subscriptionId: SubscriptionId?,
    _ subscriberId: SubscriberId?,
    _ data: Any?
) -> ()


typealias DigestOptions = String

enum RequestType: Int, Codable, CustomStringConvertible, CaseIterable {
    case subscription = 1
    case subscriptionDiff = 2
    case sendSubscriptionData = 3
    case unsubscribe = 4
    case set = 5
    case get = 6
    case configuration = 7
    case getConfiguration = 8
    case call = 9
    case getSubscription = 10
    case delete = 11
    case copy = 12
    case digest = 13
    case token = 14
    case track = 15
    
    var description: String {
        return "\(self.rawValue)"
    }
}
