//
//  Types.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

typealias SubscriptionId = UInt64
typealias SubscriberId = UInt64

typealias DataCallback = (_ data: AnyObject, _ checksum: Int) -> ()
typealias InitialCallback = (
    _ error: Error?,
    _ subscriptionId: SubscriptionId?,
    _ subscriberId: SubscriberId?,
    _ data: AnyObject?,
    _ isAuthError: Bool?
) -> ()
typealias ErrorCallback = (_ error: Error) -> ()

typealias DigestOptions = String

enum RequestTypes: Int {
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
