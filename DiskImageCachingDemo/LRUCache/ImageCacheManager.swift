//
//  ImageCacheManager.swift
//  FileStorageVSDatabase
//
//  Created by Abdelrhman Elmahdy on 06/03/2024.
//

import Foundation
import os.signpost

enum ImageRelevance: Int, Codable {
    case irrelevant
    case relevant
    case inWishlist
    case inCart
}

struct ImageCacheFile {
    let lastUpdated: Int
    let accumulativeImageSize: Int
    let imageMetaData: [String: ImageMetadata]
}

struct ImageMetadata: Codable {
    let lastUsed: Int
    let relevance: ImageRelevance
    let sizeInKiloBytes: Int
}

struct ImageCacheManager {
    let signposter = OSSignposter()
    var cacheMetadataFileURL: URL {
        diskCacheURL.appendingPathComponent("cache_metadata.json")
    }

    let diskCacheURL: URL

    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        diskCacheURL = documentsDirectory.appendingPathComponent("ImageCache")
        print(diskCacheURL.path)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
    }

    func loadMetadataFromDiskCache() -> [String: ImageMetadata]? {
        let signpostID = signposter.makeSignpostID()
        let state = signposter.beginInterval("inMemory query", id: signpostID)

        defer {
            signposter.endInterval("inMemory query", state)
        }

        guard FileManager.default.fileExists(atPath: cacheMetadataFileURL.path) else {
//            print("file doesn't exist")
            return nil
        }

        do {
            let data = try Data(contentsOf: cacheMetadataFileURL)
//            print("data: ")
//            dump(data)

            let metadata = try JSONDecoder().decode([String: ImageMetadata].self, from: data)
//            print("metadata: ")
//            dump(metadata)

            return metadata
        } catch {
//            print("failed to decode: \(error)")
            return nil
        }
    }

    func saveMetadataToDiskCache(_ metadata: [String: ImageMetadata]) async {
        let data = try! JSONEncoder().encode(metadata)
        try! data.write(to: URL(fileURLWithPath: cacheMetadataFileURL.path), options: .atomic)
    }
}
