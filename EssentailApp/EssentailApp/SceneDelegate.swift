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
     
//     let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
     
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
          
     private lazy var httpClient: HTTPClient = {
         return  URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
     }()
     
     private lazy var store: FeedStore & FeedImageDataStore = {
             try! CoreDataFeedStore(storeURL: localStoreURL)
         }()
    
     private lazy var localFeedLoader = {LocalFeedLoader(store: store, currentDate: Date.init)}()

     private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

         private lazy var navigationController = UINavigationController(
             rootViewController: FeedUIComposer.feedComposedWith(
                 feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                 imageLoader: makeLocalImageLoaderWithRemoteFallback,
                 selection: showComments))

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
         
         window?.rootViewController = navigationController
         window?.makeKeyAndVisible()
     }
    
     
     private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
         let url = FeedEndpoint.get().url(baseURL: baseURL)

         return  httpClient
                 .getPublisher(url)
                 .tryMap(FeedItemsMapper.map)
                 .caching(to: localFeedLoader)
                 .fallback(to: localFeedLoader.loadPublisher)
                 .map{
                     Paginated(items: $0)
                 }.eraseToAnyPublisher()
         
//             return remoteFeedLoader
//                 .loadPublisher()
//                 .caching(to: localFeedLoader)
//                 .fallback(to: localFeedLoader.loadPublisher)
         }
     
     private func showComments(for image: FeedImage) {
            let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
             let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
             navigationController.pushViewController(comments, animated: false)
         }
     private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
             return { [httpClient] in
                 return httpClient
                     .getPublisher(url)
                     .tryMap(ImageCommentsMapper.map)
                     .eraseToAnyPublisher()
             }
         }
     
     private func makeLocalImageLoaderWithRemoteFallback(url:URL) -> FeedImageDataLoader.Publisher {
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
