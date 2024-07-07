//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 07/04/2024.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
    
//    typealias DeletionResult = Result<Void, Error>
//    typealias DeletionCompletion = (DeletionResult) -> Void
//    
//    typealias InsertionResult = Result<Void, Error>
//    typealias InsertionCompletion = (InsertionResult) -> Void
//    
//    typealias RetrievalResult = Result<CachedFeed?, Error>
//    typealias RetrievalCompletion = (RetrievalResult) -> Void
//
//    @available(*, deprecated)
//    /// The completion handler can be invoked in any thread.
//    /// Clients are responsible to dispatch to appropriate threads, if needed.
//    func deleteCachedFeed(completion: @escaping DeletionCompletion)
//    
//    @available(*, deprecated)
//    /// The completion handler can be invoked in any thread.
//    /// Clients are responsible to dispatch to appropriate threads, if needed.
//    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
//    
//    @available(*, deprecated)
//    /// The completion handler can be invoked in any thread.
//    /// Clients are responsible to dispatch to appropriate threads, if needed.
//    func retrieve(completion: @escaping RetrievalCompletion)
}

//public extension FeedStore {
//    func deleteCachedFeed() throws {
//            let group = DispatchGroup()
//            group.enter()
//            var result: DeletionResult!
//            deleteCachedFeed {
//                result = $0
//                group.leave()
//            }
//            group.wait()
//            return try result.get()
//        }
//    
//    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
//            let group = DispatchGroup()
//            group.enter()
//            var result: InsertionResult!
//            insert(feed, timestamp: timestamp) {
//                result = $0
//                group.leave()
//            }
//            group.wait()
//            return try result.get()
//        }
//    
//    func retrieve() throws -> CachedFeed? {
//            let group = DispatchGroup()
//            group.enter()
//            var result: RetrievalResult!
//            retrieve {
//                result = $0
//                group.leave()
//            }
//            group.wait()
//            return try result.get()
//        }
//
//    func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
//    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {}
//    func retrieve(completion: @escaping RetrievalCompletion) {}
//}
