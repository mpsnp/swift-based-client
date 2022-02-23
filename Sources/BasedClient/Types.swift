//
//  Types.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//


public typealias DataCallback = (_ data: Any, _ checksum: Int) -> ()
public typealias ErrorCallback = (_ error: BasedError) -> ()

typealias DigestOptions = String

enum RequestType: Int, Codable, CustomStringConvertible, CaseIterable {
    case subscription = 1,
    subscriptionDiff = 2,
    sendSubscriptionData = 3,
    unsubscribe = 4,
    set = 5,
    get = 6,
    configuration = 7,
    getConfiguration = 8,
    call = 9,
    getSubscription = 10,
    delete = 11,
    copy = 12,
    digest = 13,
    token = 14,
    track = 15
    
    var description: String {
        return "\(self.rawValue)"
    }
}
