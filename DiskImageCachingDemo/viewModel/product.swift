//
//  product.swift
//  DiskImageCachingDemo
//
//  Created by Ramy Nasser on 12/03/2024.
//

import Foundation
import Foundation

// MARK: - Welcome
struct ProductResponse: Codable {
    let items: [Product]
    let totalItems, page, size, totalPages: Int

    enum CodingKeys: String, CodingKey {
        case items
        case totalItems = "total_items"
        case page, size
        case totalPages = "total_pages"
    }
}

// MARK: - Item
struct Product: Codable {
    let guid, sku: String
    let name: Name
    let price: Price
    let quantity: Int
    let isSponsored, inStock: Bool
    let rating: Double
    let thumbnails: [String]
}

enum Name: String, Codable {
    case camera = "Camera"
    case gamingConsole = "Gaming Console"
    case headphones = "Headphones"
    case laptop = "Laptop"
    case smartphone = "Smartphone"
    case smartwatch = "Smartwatch"
    case tablet = "Tablet"
    case tv = "TV"
}

// MARK: - Price
struct Price: Codable {
    let regular, priceFinal: Double
    let currency: String

    enum CodingKeys: String, CodingKey {
        case regular
        case priceFinal = "final"
        case currency
    }
}
