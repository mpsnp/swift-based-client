//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 02/10/2021.
//

import Foundation
#if os(Linux)
import Dispatch
#endif

final class QueueManager {
    
    private let dispatchQueue: DispatchQueue
    private var workItems = [Int: DispatchWorkItem]()
    
    init(_ queue: DispatchQueue = DispatchQueue(label: "com.based.queue.manager", attributes: .concurrent)) {
        self.dispatchQueue = queue
    }
    
    deinit {
        cancelQueuedItems()
    }
    
    func dispatch(item: @escaping ()->Void, cancelable: Bool = true) {
        if cancelable {
            let dispatchWorkItem = DispatchWorkItem(flags: .barrier, block: item)
            let index = workItems.count
            workItems[workItems.count] = dispatchWorkItem
            dispatchWorkItem.notify(queue: dispatchQueue) { [weak self, index] in
                self?.removeItem(index: index)
            }
            dispatchQueue.async(execute: dispatchWorkItem)
        } else {
            dispatchQueue.async {
                item()
            }
        }
    }
    
    private func removeItem(index: Int) {
        workItems[index] = nil
    }
    
    func cancelQueuedItems() {
        workItems.forEach { (key, value) in
            value.cancel()
            workItems[key] = nil
        }
    }
}
