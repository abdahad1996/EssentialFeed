//
//  SceneDelegate.swift
//  EssentailApp
//
//  Created by macbook abdul on 16/06/2024.
//

import UIKit
import EssentialFeed
import CoreData
import Combine

 class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
     
    let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
     
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
     
     lazy var navigationController = UINavigationController()
     
     private lazy var httpClient: HTTPClient = {
         return  URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
     }()
     
     private lazy var store: FeedStore & FeedImageDataStore = {
             try! CoreDataFeedStore(storeURL: localStoreURL)
         }()
    
     private lazy var localFeedLoader = {LocalFeedLoader(store: store, currentDate: Date.init)}()


     private lazy var remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)

     convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
             self.init()
             self.httpClient = httpClient
             self.store = store
         }
     
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
     }
     
     func configureWindow(){
         
         window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader:makeLocalImageLoaderWitRemoteFallback
         ))
         window?.makeKeyAndVisible()
     }
    
     
     private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
             return remoteFeedLoader
                 .loadPublisher()
                 .caching(to: localFeedLoader)
                 .fallback(to: localFeedLoader.loadPublisher)
         }
     
     private func makeLocalImageLoaderWitRemoteFallback(url:URL) -> FeedImageDataLoader.Publisher {
         let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
         let localImageLoader = LocalFeedImageDataLoader(store: store)
         
         return localImageLoader
             .loadImageDataPublisher(url)
             .fallback {
                 remoteImageLoader
                     .loadImageDataPublisher(url)
                     .caching(to: localImageLoader, using: url)
             }
     }

    func sceneWillResignActive(_ scene: UIScene) {
             localFeedLoader.validateCache { _ in }
        }
    
}

public extension FeedImageDataLoader{
    typealias Publisher = AnyPublisher<Data,Error>
    
    public func loadImageDataPublisher(_ url:URL) -> Publisher {
        var task:FeedImageDataLoaderTask?
        return Deferred {
            Future{ promise in
                task = self.loadImageData(from: url, completion: promise)
            }
        }.handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache,using url:URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}




public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>

    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}


extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {

    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }

    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()

                private static let key = DispatchSpecificKey<UInt8>()
                private static let value = UInt8.max

                private init() {
                    DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
                }

                private func isMainQueue() -> Bool {
                    DispatchQueue.getSpecific(key: Self.key) == Self.value
                }

        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }

            action()
        }

        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
