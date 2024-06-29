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
     
     let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
     
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


//     private lazy var remoteFeedLoader = RemoteLoader(url: remoteURL, client: httpClient,mapper: FeedItemsMapper.map)

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
    
     
     private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
         return  httpClient
                 .getPublisher(remoteURL)
                 .tryMap(FeedItemsMapper.map)
                 .caching(to: localFeedLoader)
                 .fallback(to: localFeedLoader.loadPublisher)
         
//             return remoteFeedLoader
//                 .loadPublisher()
//                 .caching(to: localFeedLoader)
//                 .fallback(to: localFeedLoader.loadPublisher)
         }
     
     private func makeLocalImageLoaderWitRemoteFallback(url:URL) -> FeedImageDataLoader.Publisher {
//         let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
         let localImageLoader = LocalFeedImageDataLoader(store: store)
         
         return localImageLoader
             .loadImageDataPublisher(url)
             .fallback { [httpClient] in
                 httpClient
                     .getPublisher(url)
                     .tryMap(FeedImageDataMapper.map)
                     .caching(to: localImageLoader, using: url)
             }
//         return localImageLoader
//             .loadImageDataPublisher(url)
//             .fallback {
//                 remoteImageLoader
//                     .loadImageDataPublisher(url)
//                     .caching(to: localImageLoader, using: url)
                 
//             }
     }

    func sceneWillResignActive(_ scene: UIScene) {
             localFeedLoader.validateCache { _ in }
        }
    
}

//extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
