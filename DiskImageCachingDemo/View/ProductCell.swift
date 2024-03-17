//
//  ProductCell.swift
//  DiskImageCachingDemo
//
//  Created by Ramy Nasser on 12/03/2024.
//

import SwiftUI
import Combine
struct ProductCell: View {
    var product: Product

    var body: some View {
        HStack(spacing: 8) {
            ProductPosterView(imageURL:"https://picsum.photos/300?random=\(Int.random(in: 1...1000))", imageKey: product.thumbnails.first ?? "")
                .id(UUID())
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name.rawValue ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.leading)

                Text(product.guid ?? "")
                    .font(.system(size: 14))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(8)
    }
}

struct ProductPosterView: View {
    var imageURL: String
    var imageKey: String

    @StateObject private var viewModel = ProductPosterViewModel()

    var body: some View {
        Image(uiImage: viewModel.image ?? UIImage())
            .resizable()
            .scaledToFit()
            .onAppear {
                guard let url = URL(string: imageURL) else { return }
                viewModel.loadImage(from: url, key: imageKey)

            }.onDisappear {
                viewModel.cancelLoadImage()
            }
    }
}

