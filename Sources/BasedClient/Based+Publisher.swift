//
//  Based+Publisher.swift
//  
//
//  Created by Alexander van der Werff on 13/01/2022.
//
#if os(iOS)

import Foundation
import Combine


extension Based {
    
    public struct DataPublisher<T: Decodable>: Publisher {
        
        public typealias Failure = Error
        public typealias Output = T
    
        private let based: Based
        private let type: SubscriptionType

        init(type: SubscriptionType, based: Based) {
            self.type = type
            self.based = based
        }
        
        public func receive<S: Subscriber>(
            subscriber: S
        ) where S.Input == Output, S.Failure == Failure {
            
            Task {
                let subscription = await DataSubscription(type: type, based: based, subscriber: subscriber)
        
                subscriber.receive(subscription: subscription)
            }
        }
    }
    
    class DataSubscription<S: Subscriber, T: Decodable>: Combine.Subscription where S.Input == T, S.Failure == Error {
        
        private var based: Based?
        private let type: SubscriptionType
        private let subscriptionId: SubscriptionId
        private var subscriber: S?
        private var payload: JSON = JSON.null
        private var name: String? = nil
        private let dataCallback: DataCallback
        private let initialCallback: InitialCallback
        private let errorCallback: ErrorCallback
        private let ids: (subscriptionId: SubscriptionId, subscriberId: SubscriptionId)
        
        init(type: SubscriptionType, based: Based, subscriber: S) async {
            self.based = based
            self.type = type
            self.subscriptionId = type.generateSubscriptionId()
            self.subscriber = subscriber
            
            switch type {
            case .query(let query):
                if let p = try? JSON(query.dictionary()) {
                    payload = p
                }
            case .func(let n, let pay):
                name = n
                if let pay = pay,  let p = try? JSON(pay) {
                    payload = p
                }
            }
            
            dataCallback = { data, checksum in
                guard let data = data as? Data else {
                    return
                }
                Self.handleData(subscriber: subscriber, data: data, based: based)
            }
            
            initialCallback = { error, subscriptionId, subscriberId, data, isAuthError in
                if let error = error {
                    subscriber.receive(completion: Subscribers.Completion.failure(error))
                    return
                }
                guard let data = data as? Data else {
                    return
                }
                Self.handleData(subscriber: subscriber, data: data, based: based)
            }
            
            errorCallback = { error in
                subscriber.receive(completion: Subscribers.Completion.failure(error))
            }
            
            ids = await based.addSubscriber(
                payload: payload,
                onData: dataCallback,
                onInitial: initialCallback,
                onError: errorCallback,
                subscriptionId: subscriptionId,
                name: name
            )
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            Task { await based?.removeSubscriber(subscriptionId: ids.subscriptionId, subscriberId: ids.subscriberId) }
            subscriber = nil
            based = nil
        }
        
        private static func handleData(subscriber: S, data: Data, based: Based) {
            
            do {
                let result = try based.decoder.decode(T.self, from: data)
                _ = subscriber.receive(result)
            } catch {
                subscriber.receive(completion: Subscribers.Completion.failure(error))
            }
            
        }
        
    }
    
    public func publisher<T: Decodable>(query: Query) -> DataPublisher<T> {
        return DataPublisher(type: .query(query), based: self)
    }
    
    public func publisher<T: Decodable>(name: String, payload: Any?) -> DataPublisher<T> {
        return DataPublisher(type: .func(name, payload), based: self)
    }
    
}

#endif
