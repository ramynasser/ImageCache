//
//  MoviesView.swift
//  ImageCacheDemo
//
//  Created by Ramy Nasser on 28/02/2024.
//

import Foundation
import SwiftUI
import Combine

struct MoviesView: View {
    @ObservedObject private var viewModel = MoviesViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.movies) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    MovieCell(movie: movie)
                }
            }
            .navigationTitle("Movies")
        }
        .onAppear {
            viewModel.loadMovies()
        }
    }
}

struct PLPView: View {
    @ObservedObject private var viewModel = ProductViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.products, id: \.guid) { product in
                NavigationLink(destination: PDPView(product: product)) {
                    ProductCell(product: product)
                        .onAppear {
                            DispatchQueue.main.async {
                                viewModel.forceUpdate()
                            }
                        }
                }
            }
            .navigationTitle("Products")
        }
        .onAppear {
            viewModel.loadMovies()
        }
    }
}

struct MovieDetailView: View {
    var movie: Movie

    var body: some View {
        VStack {
            MoviePosterView(posterURL: movie.poster)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .edgesIgnoringSafeArea(.top)

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(movie.overview)
                    .font(.body)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .padding(.top, -32)
            .shadow(radius: 4)
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct PDPView: View {
    var product: Product

    var body: some View {
        VStack {
            ProductPosterView(imageURL: "https://picsum.photos/300", imageKey: product.thumbnails.first ?? "")
                .frame(maxWidth: .infinity, maxHeight: 300)
                .edgesIgnoringSafeArea(.top)

            VStack(alignment: .leading, spacing: 8) {
                Text(product.name.rawValue)
                    .font(.title)
                    .fontWeight(.bold)

                Text(product.guid)
                    .font(.body)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .padding(.top, -32)
            .shadow(radius: 4)
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
