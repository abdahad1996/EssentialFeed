//
//  HttpClientStub.swift
//  EssentailAppTests
//
//  Created by macbook abdul on 20/06/2024.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
    func deleteCachedFeed() throws {
        feedCache = nil
    }
//    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
//        feedCache = nil
//        completion(.success(()))
//    }
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        feedCache = CachedFeed(feed: feed, timestamp: timestamp)
    }
    
    func retrieve() throws -> CachedFeed? {
        return .none
    }

//    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
//        feedCache = CachedFeed(feed: feed, timestamp: timestamp)
//        completion(.success(()))
//    }

//    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
//        completion(.success(feedCache))
//    }

//    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
//        feedImageDataCache[url] = data
//        completion(.success(()))
//    }
//
//    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
//        completion(.success(feedImageDataCache[url]))
//    }

    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore{
        let feedCache = CachedFeed(feed: [], timestamp: .distantPast)
        return InMemoryFeedStore(feedCache:feedCache)
    }
    static var withNonExpiredFeedCache: InMemoryFeedStore{
        let feedCache = CachedFeed(feed: [], timestamp: .distantFuture)
        return InMemoryFeedStore(feedCache:feedCache)
    }
    
}

extension InMemoryFeedStore:FeedImageDataStore{
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
}
