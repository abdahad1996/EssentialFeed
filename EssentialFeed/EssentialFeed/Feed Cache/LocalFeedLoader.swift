//
//  LocalFeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 07/05/2024.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader:FeedCache {
//    public typealias SaveResult = FeedCache.Result
    public func save(_ feed: [FeedImage]) throws
    {
        try store.deleteCachedFeed()
        try self.store.insert(feed.toLocal(), timestamp: currentDate())
    }
//    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
////        store.deleteCachedFeed { [weak self] deletionResult in
////            guard let self = self else { return }
////            
////            switch deletionResult {
////            case .success:
////                self.cache(feed, with: completion)
////            
////            case let .failure(error):
////                completion(.failure(error))
////            }
////        }
//        
//        completion(SaveResult {
//            try store.deleteCachedFeed()
//            try self.store.insert(feed.toLocal(), timestamp: currentDate())
//        })
//    }
    
//    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
//        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
//            guard self != nil else { return }
//            
//            completion(insertionResult)
//        }
//    }
}

extension LocalFeedLoader {
//    public typealias LoadResult = Swift.Result<[FeedImage], Error>

    public func load() throws -> [FeedImage]  {
        if let cache = try store.retrieve(),
            CachePolicy.validateCache(cache.timestamp, against: self.currentDate()){
            return cache.feed.toModels()
        }
        return []
    }
//    public func load(completion: @escaping (LoadResult) -> Void) {
//        
//        
////        store.retrieve { [weak self] result in
////            guard let self = self else { return }
////
//        
////            switch result {
////            case let .failure(error):
////                completion(.failure(error))
////
////            case let .success(.some(cache)) where CachePolicy.validateCache(cache.timestamp, against: self.currentDate()):
////                completion(.success(cache.feed.toModels()))
////
////            case .success:
////                completion(.success([]))
////            }
////        }
//        completion(LoadResult{
//            if let cache = try store.retrieve(),
//                CachePolicy.validateCache(cache.timestamp, against: self.currentDate()){
//                return cache.feed.toModels()
//            }
//            return []
//        })
//    }
    
    
}

extension LocalFeedLoader {
//    public typealias ValidationResult = Result<Void, Error>
    private struct InvalidCache: Error {}

//    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
//        store.retrieve { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//            case .failure:
//                self.store.deleteCachedFeed(completion: completion)
//
//                
//            case let .success(.some(cache)) where !CachePolicy.validateCache(cache.timestamp, against: self.currentDate()):
//                self.store.deleteCachedFeed(completion: completion)
//
//                
//            case .success:
//                completion(.success(()))
//            }
//        }
//    }
    public func validateCache() throws {
        do {

        if let cache = try store.retrieve(), !CachePolicy.validateCache(cache.timestamp, against: currentDate()) {
            throw InvalidCache()
        }
        } catch {
            try store.deleteCachedFeed()
        }
    }
//    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
//        completion(ValidationResult{
//            do {
//
//            if let cache = try store.retrieve(), !CachePolicy.validateCache(cache.timestamp, against: currentDate()) {
//                throw InvalidCache()
//            }
//            } catch {
//                try store.deleteCachedFeed()
//            }
//        })
//        
//    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
