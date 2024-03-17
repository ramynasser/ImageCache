//
//  MoviesViewModel.swift
//  ImageCacheDemo
//
//  Created by Ramy Nasser on 28/02/2024.
//

import SwiftUI
import Combine

class MoviesViewModel: ObservableObject {
    @Published var movies = [Movie]()

    func loadMovies() {
        if let path = Bundle.main.path(forResource: "movies", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                movies = try JSONDecoder().decode([Movie].self, from: data)
            } catch {
                print("Error loading movies: \(error.localizedDescription)")
            }
        }
    }
}

class ProductViewModel: ObservableObject {
    @Published var products = [Product]()
    @Published var updateTrigger: Bool = false

    func loadMovies() {
        if let path = Bundle.main.path(forResource: "Products", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let resposne = try JSONDecoder().decode(ProductResponse.self, from: data)
                products = resposne.items
            } catch {
                print("Error loading movies: \(error.localizedDescription)")
            }
        }
    }
    func forceUpdate() {
        updateTrigger.toggle()
    }
}
