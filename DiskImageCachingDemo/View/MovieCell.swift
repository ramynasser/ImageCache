//
//  MovieCell.swift
//  ImageCacheDemo
//
//  Created by Ramy Nasser on 28/02/2024.
//

import SwiftUI
import Combine
struct MovieCell: View {
    var movie: Movie

    var body: some View {
        HStack(spacing: 8) {
            MoviePosterView(posterURL: movie.poster)

            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.leading)

                Text(movie.overview)
                    .font(.system(size: 14))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(8)
    }
}

struct MoviePosterView: View {
    var posterURL: String

    @StateObject private var viewModel = MoviePosterViewModel()

    var body: some View {
        Image(uiImage: viewModel.image ?? UIImage())
            .resizable()
            .scaledToFit()
            .onAppear {
                guard let url = URL(string: posterURL) else { return }
                viewModel.loadImage(from: url, key: url.lastPathComponent)
            }
    }
}

