//
//  Types.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

typealias SubscriptionId = UInt64
typealias SubscriberId = UInt64
typealias Subscriptions = Dictionary<SubscriberId, Subscription>

typealias DataCallback = (_ data: JSON, _ checksum: UInt64) -> ()
typealias InitialCallback = (
    _ error: Error?,
    _ subscriptionId: SubscriptionId?,
    _ subscriberId: SubscriberId?,
    _ data: JSON?,
    _ isAuthError: Bool?
) -> ()
typealias ErrorCallback = (_ error: Error) -> ()

typealias DigestOptions = String

enum RequestType: Int, Codable {
  case subscription = 1,
  subscriptionDiff,
  sendSubscriptionData,
  unsubscribe,
  set,
  get,
  configuration,
  getConfiguration,
  call,
  getSubscription,
  delete,
  copy,
  digest,
  token
}
