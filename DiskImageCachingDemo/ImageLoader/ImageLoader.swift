import Foundation
import UIKit.UIImage
import Combine
public final class ImageLoader {
    public static let shared = ImageLoader()
    
    private let cache: ImageCacheType
    private lazy var backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    
    private var cancellables: Set<AnyCancellable> = Set()

    public init(cache: ImageCacheType = ImageCache()) {
        self.cache = cache
    }
    
    
    public func loadImage(from url: URL, key: String) -> AnyPublisher<UIImage?, Never> {
        if cache.cacheType(key: key).cached {
            return Just(())
                .flatMap { _ in
                    self.retrieveCachedImage(url: url, key: key)
                }
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .flatMap { _ in
                    self.retrieveAndCacheImage(url: url, key: key)
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func retrieveCachedImage(url: URL, key: String) -> AnyPublisher<UIImage?, Never> {
        return Future<UIImage?, Never> { promise in
            self.cache.image(for: key) { image in
                if let image = image {
                    promise(.success(image))
                } else {
                    self.retrieveAndCacheImage(url: url, key: key)
                        .sink { image in
                            promise(.success(image))
                        }
                        .store(in: &self.cancellables)

                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    private func retrieveAndCacheImage(url: URL, key: String) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) -> UIImage? in
                return UIImage(data: data)
            }
            .catch { error in return Just(nil) }
            .handleEvents(receiveOutput: {[unowned self] image in
                guard let image = image else { return }
                
                self.cache.insertImage(image, for: key)
            })
            .print("Image loading \(key):")
            .subscribe(on: backgroundQueue)
            .eraseToAnyPublisher()
        
    }


}

