//
//  SceneDelegate.swift
//  EssentailApp
//
//  Created by macbook abdul on 16/06/2024.
//

import UIKit
import EssentialFeed
import CoreData

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

     convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
             self.init()
             self.httpClient = httpClient
             self.store = store
         }
     
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
        
        
    }
     
     func configureWindow(){
         
         let remoteClient = makeRemoteClient()
         let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
         let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
         
         let localImageLoader = LocalFeedImageDataLoader(store: store)
         
         
         
         window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            loader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    loader: remoteFeedLoader,
                    cache: localFeedLoader
                ),
                fallback: localFeedLoader
            ),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader
                )
            )
         ))
         
     }
    
     func makeRemoteClient() -> HTTPClient {
        return httpClient
    }
     
    func sceneWillResignActive(_ scene: UIScene) {
             localFeedLoader.validateCache { _ in }
        }
    
}


