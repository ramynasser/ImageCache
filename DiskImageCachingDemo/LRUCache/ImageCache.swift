//
//  ImageCache.swift
//  DiskImageCachingDemo
//
//  Created by Ramy Nasser on 29/02/2024.
//

import Foundation
import UIKit.UIImage
import Combine

public protocol ImageCacheType: class {
    func image(for key: String, completion: @escaping (UIImage?) -> Void)
    func insertImage(_ image: UIImage?, for url: String)
    func removeImage(for url: String)
    func removeAllImages()
    func cacheType(key: String) -> CacheType
}
public enum CacheType {
    case none
    case memory
    case disk
    
    /// Whether the cache type represents the image is already cached or not.
    public var cached: Bool {
        switch self {
        case .memory, .disk: return true
        case .none: return false
        }
    }
}
public class ImageCache: ImageCacheType {

    private var memoryCache: LRUCache<String, CodableImage>
    private var diskCache: LRUDiskCache<String, CodableImage>
    private let lock = NSLock()

    public init() {
        self.memoryCache = LRUCache<String, CodableImage>(capacity: 20)
        self.diskCache = LRUDiskCache<String, CodableImage>()
    }

    public func cacheType(key: String) -> CacheType {
        if memoryCache.isCached(for: key) {
            return .memory
        } else if diskCache.isCached(for: key) {
            return .disk
        } else {
            return .none
        }
    }
    public func image(for key: String, completion: @escaping (UIImage?) -> Void) {
            lock.lock()
            defer { lock.unlock() }

            // Attempt to retrieve the image from the memory cache
            if let image = memoryCache.retrieveObject(at: key) {
                // If the image is found in the memory cache, return it via the completion handler
                completion(image.getImage())
                return
            }

            // If the image is not found in the memory cache, retrieve it from the disk cache
            diskCache.retrieveObject(at: key) { [weak self] data in
                guard let self = self, let data = data, let image = UIImage(data: data.data) else {
                    // If there's no image data or self is deallocated, return nil via the completion handler
                    completion(nil)
                    return
                }

                // Set the retrieved image to the memory cache
                let decompressedImage = image.decodedImage()
                self.memoryCache.setObject(for: key, value: CodableImage(decompressedImage))

                // Return the retrieved image via the completion handler
                completion(image)
            }
        }
    public func insertImage(_ image: UIImage?, for key: String) {
        guard let image = image else {
            removeImage(for: key)
            return
        }

        lock.lock(); defer { lock.unlock() }
        let decompressedImage = image.decodedImage()
        memoryCache.setObject(for: key, value: CodableImage(decompressedImage))
        diskCache.setObject(for: key, value: CodableImage(decompressedImage))
    }

    public func removeImage(for key: String) {
        lock.lock(); defer { lock.unlock() }

        memoryCache.removeObject(for: key)
    }

    public func removeAllImages() {
        lock.lock(); defer { lock.unlock() }

        memoryCache.removeAllObjects()
    }
    
    // memory storage
    private static func createMemoryStorage() -> Int  {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4
        let memoryStorage = (costLimit > Int.max) ? Int.max : Int(costLimit)
        return memoryStorage
    }
}

// Wrapper struct to make UIImage conform to Codable
public struct CodableImage: Codable {
    let data: Data

    init(_ image: UIImage) {
        self.data = image.jpegData(compressionQuality: 0.1) ?? Data()
    }

    func getImage() -> UIImage? {
        return UIImage(data: data)
    }
}
