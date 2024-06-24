////
////  FeedLoaderWithFallbackComposite.swift
////  EssentailApp
////
////  Created by macbook abdul on 16/06/2024.
////
//
//import Foundation
//import EssentialFeed
//import Combine
//
// 
//public class FeedLoaderCacheDecorator:FeedLoader{
//    
//    let loader:FeedLoader
//    let cache:FeedCache
//    
//    public init(loader: FeedLoader, cache: FeedCache) {
//        self.loader = loader
//        self.cache = cache
//    }
//    
//    public func load(completion: @escaping (Result<[EssentialFeed.FeedImage], any Error>) -> Void) {
//        loader.load { [weak self] result in
//            completion(result.map{feed in
//                self?.cache.saveIgnoringResult(feed)
//                return feed
//            })
//        }
//    }
//    
//}
//
//private extension FeedCache {
//    func saveIgnoringResult(_ feed: [FeedImage]) {
//        save(feed) { _ in }
//    }
//}
//
//
