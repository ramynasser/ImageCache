# Image Caching 

Disk Image Caching Demo is a Swift library that demonstrates how to implement disk and memory caching for images retrieved from remote URLs using an LRU (Least Recently Used) caching strategy.

## Features

- Efficient caching of images in memory and on disk
- LRU caching strategy for optimal performance
- Supports retrieval of cached images by key
- Easy-to-use API for integrating image caching into your apps

## Usage

To use the Image Caching Demo ImageLoader in your Swift project, follow these steps:

1. Create an instance of ImageLoader:

   ```swift
   let imageLoader = ImageLoader.shared

2. Load an image from a remote URL with a specified key:

   ```swift
   let imageKey = imageURL.absoluteString

   imageLoader.loadImage(from: imageURL, key: imageKey)
   .sink { image in
        // Handle the loaded image
   }
   .store(in: &cancellables)
