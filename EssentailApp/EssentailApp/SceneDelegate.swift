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
         do {
             return try CoreDataFeedStore(storeURL: localStoreURL)
         } catch {
             return NullStore()
         }
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
         makeRemoteFeedLoader()
                     .caching(to: localFeedLoader)
                     .fallback(to: localFeedLoader.loadPublisher)
                     .map(makeFirstPage)
                     .eraseToAnyPublisher()
         }
     
     private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
         localFeedLoader.loadPublisher()
             .zip(makeRemoteFeedLoader(after: last))
             .map { (cachedItems, newItems) in
                 (cachedItems + newItems, newItems.last)
             }
             .map(makePage)
             .caching(to: localFeedLoader)
             .eraseToAnyPublisher()
     }
     
     private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
         let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
         
         return httpClient
             .getPublisher(url)
             .tryMap(FeedItemsMapper.map)
             .eraseToAnyPublisher()
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
     
     private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
         makePage(items: items, last: items.last)
     }
     
     private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
         Paginated(items: items, loadMorePublisher: last.map { last in
             { self.makeRemoteLoadMoreLoader(last: last) }
         })
     }

}

//extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
