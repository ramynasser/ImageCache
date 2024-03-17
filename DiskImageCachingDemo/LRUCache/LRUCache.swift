//
//  LRUCache.swift
//  DiskImageCachingDemo
//
//  Created by Ramy Nasser on 29/02/2024.
//

import Foundation
class LRUCache<T: Hashable, U> {
    
    private var capacity: UInt
    private var linkedList = DoublyLinkedList<CachePayload<T, U>>()
    private var dictionary = [T: Node<CachePayload<T, U>>]()
    private let lock = NSLock() // Add NSLock for synchronization
    private var cleanTimer: Timer? = nil
    var count: UInt = 0  // Add count property
    var keys = Set<String>()
    init(capacity: UInt) {
        self.capacity = capacity
        cleanTimer = .scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.removeExpired()
        }
    }
    
    func isCached(for key: any Hashable) -> Bool {
        retrieveObject(at: key as! T) != nil 
    }
    /// Removes the expired values from the storage.
    public func removeExpired() {
    }
    func setObject(for key: T, value: U) {
        lock.lock()
        defer { lock.unlock() }
        
        let element = CachePayload(key: key, value: value)
        let node = Node(value: element)
        
        
        if let existingNode = dictionary[key] {
            linkedList.moveToHead(node: existingNode)
            linkedList.head?.payload.value = value
            dictionary[key] = node
        } else {
            if linkedList.count == capacity {
                if let leastAccessedKey = linkedList.tail?.payload.key {
                    dictionary[leastAccessedKey] = nil
                }
                linkedList.remove()
            }
            
            linkedList.insert(node: node, at: 0)
            dictionary[key] = node
        }
        
        count += 1  // Increment count
        keys.insert(key as! String)
    }
    
    func retrieveObject(at key: T) -> U? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let existingNode = dictionary[key] else {
            return nil
        }
        
        linkedList.moveToHead(node: existingNode)
        return existingNode.payload.value
    }
    
    func removeObject(for key: T) {
        lock.lock()
        defer { lock.unlock() }
        
        if let node = dictionary[key] {
            linkedList.remove(node: node)
            dictionary[key] = nil
        }
    }
    
    func removeLeastRecentlyUsed() -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let leastUsedKey = linkedList.tail?.payload.key else {
            return nil
        }
        
        linkedList.remove(node: linkedList.tail!)
        dictionary[leastUsedKey] = nil
        
        count -= 1  // Decrement count
        
        return leastUsedKey
    }
    
    func removeAllObjects() {
        lock.lock()
        defer { lock.unlock() }
        
        linkedList = DoublyLinkedList<CachePayload<T, U>>()
        dictionary.removeAll()
    }
}
