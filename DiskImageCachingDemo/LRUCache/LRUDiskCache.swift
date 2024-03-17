//
//  LRUDiskCache.swift
//  DiskImageCachingDemo
//
//  Created by Ramy Nasser on 29/02/2024.
//

import Foundation


class LRUDiskCache<T: StringProtocol, U: Codable> {
    
    private var capacity: UInt
    private var diskStorage: DiskStorage
    
    private let lock = NSLock()
    private let fileAccessQueue = DispatchQueue(label: "com.example.LRUDiskCache.fileAccess")
    
    init(capacity: UInt = 100) {
        self.capacity = capacity
        self.diskStorage = DiskStorage()
    }
    
    func isCached(for key: String) -> Bool {
        ((diskStorage.maybeCached?.contains(key)) != nil)
    }
    
    func setObject(for key: T, value: U) {
        lock.lock(); defer { lock.unlock() }
        fileAccessQueue.async {
            self.diskStorage.storeObject(value, forKey: key as! String )
        }
    }
    
    func retrieveObject(at key: T, completion: @escaping (U?) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        
        let retrievedKey = key as? String ?? ""
        fileAccessQueue.async {
            self.diskStorage.retrieveObject(forKey: retrievedKey) { [weak self] (object: U?) in
                guard let object = object else {
                    completion(nil)
                    return
                }
                DispatchQueue.main.async {
                    completion(object)
                }
            }
        }
    }
    func removeObject(for key: T) {
        lock.lock(); defer { lock.unlock() }
        diskStorage.removeObject(forKey: key as! String)
    }
    
    func removeAllObjects() {
        lock.lock(); defer { lock.unlock() }
        diskStorage.removeAllObjects()
    }
}
