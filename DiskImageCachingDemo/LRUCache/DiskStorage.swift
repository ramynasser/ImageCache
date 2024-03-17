//
//  DiskStorage.swift
//  DiskImageCachingDemo
//
//  Created by Ramy Nasser on 29/02/2024.
//

import Foundation
import UIKit.UIImage
import Combine
import SwiftUI
import os.signpost

// MARK: - Disk Storage

class DiskStorage {

    private let fileManager = FileManager.default
    private let storageDirectory: URL
    private let fileAccessQueue = DispatchQueue(label: "com.example.diskStorage")
    private let maybeCachedCheckingQueue = DispatchQueue(label: "com.example.diskStorage.maybeCachedCheckingQueue")
    var maybeCached : Set<String>?

    init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        storageDirectory = cachesDirectory.appendingPathComponent("LRUDiskCache")

        if !fileManager.fileExists(atPath: storageDirectory.path) {
            do {
                try fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create LRUDiskCache directory: \(error)")
            }
        }
        // load all meta data
        //setupCacheChecking()
        retrieveAllKeys()
    }
    private func retrieveAllKeys() {
        maybeCachedCheckingQueue.async {
            do {
                self.maybeCached = Set()
                try self.fileManager.contentsOfDirectory(atPath: self.storageDirectory.path).forEach { fileName in
                    self.maybeCached?.insert(fileName)
                }
            } catch {
                // Just disable the functionality if we fail to initialize it properly. This will just revert to
                // the behavior which is to check file existence on disk directly.
                self.maybeCached = nil
            }
        }
    }
    func storeObject<T: Codable>(_ object: T, forKey key: String) {
        fileAccessQueue.async {
            let fileURL = self.fileURL(forKey: key)
            do {
                let data = try JSONEncoder().encode(object)
                try data.write(to: fileURL)
            } catch {
                print("Failed to store data to disk for key \(key): \(error)")
            }
        }
        // write to meta data file
//        maybeCachedCheckingQueue.async {
//            self.cacheMetaData(key: key)
//        }
    }

    func retrieveObject<T: Codable>(forKey key: String, completion: @escaping (T?) -> Void) {
        fileAccessQueue.async {
            let fileURL = self.fileURL(forKey: key)
            do {
                let data = try Data(contentsOf: fileURL)
                let object = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(object)
                }
            } catch {
                print("Failed to retrieve data from disk for key \(key): \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    func removeObject(forKey key: String) {
        fileAccessQueue.async {
            let fileURL = self.fileURL(forKey: key)
            do {
                try self.fileManager.removeItem(at: fileURL)
            } catch {
                print("Failed to remove file for key \(key): \(error)")
            }
        }
    }

    func removeAllObjects() {
        fileAccessQueue.async {
            do {
                let contents = try self.fileManager.contentsOfDirectory(at: self.storageDirectory, includingPropertiesForKeys: nil, options: [])
                for fileURL in contents {
                    try self.fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("Failed to remove all files: \(error)")
            }
        }
    }
    private func fileURL(forKey key: String) -> URL {
        let fileManager = FileManager.default
        let fileName = cacheFileName(forKey: key)
        let fileURL = storageDirectory.appendingPathComponent(fileName, isDirectory: false)

        do {
            // Get the current attributes
            var attributes = try fileManager.attributesOfItem(atPath: fileURL.path)

            // Update the modification date attribute
            attributes[.type] = Date()
            attributes[.modificationDate] = Date()
            // Set the updated attributes
            try fileManager.setAttributes(attributes, ofItemAtPath: fileURL.path)
        } catch {
            print("Error setting file attributes: \(error)")
        }
        return fileURL
    }
    
    func cacheFileName(forKey key: String) -> String {
        return key
    }

   
}
