//
//  MoviePosterViewModel.swift
//  ImageCacheDemo
//
//  Created by Ramy Nasser on 28/02/2024.
//

import Foundation
import SwiftUI
import Combine
class MoviePosterViewModel: ObservableObject {
    @Published var image: UIImage?

    private var cancellable: AnyCancellable?

    func loadImage(from url: URL, key: String) {
        cancellable = ImageLoader.shared.loadImage(from: url, key: key)
            .receive(on: DispatchQueue.main)
            .sink { loadedImage in
                self.image = loadedImage
            }
    }

    func cancelLoadImage() {
        cancellable?.cancel()
    }
}


class ProductPosterViewModel: ObservableObject {
    @Published var image: UIImage?

    private var cancellable: AnyCancellable?

    func loadImage(from url: URL, key: String) {
        cancellable = ImageLoader.shared.loadImage(from: url, key: key)
            .receive(on: DispatchQueue.main)
            .sink { loadedImage in
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
    }

    func cancelLoadImage() {
        cancellable?.cancel()
    }
}
