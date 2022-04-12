//
//  Cache.swift
//  
//
//  Created by Alexander van der Werff on 11/04/2022.
//

import Foundation


typealias CacheItem = (value: Data, checksum: Int)

actor Cache {
    private var storage = [SubscriptionId: CacheItem]()
    
    func store(_ id: SubscriptionId, data: CacheItem) {
        storage[id] = data
    }
    
    func fetch(with id: SubscriptionId) -> CacheItem? {
        storage[id]
    }
    
    func remove(with id: SubscriptionId) {
        storage.removeValue(forKey: id)
    }
    
    func all() -> [SubscriptionId: CacheItem]{
        storage
    }
    
    func remove(ids: [SubscriptionId]) {
        ids.forEach { id in
            storage.removeValue(forKey: id)
        }
    }
}
