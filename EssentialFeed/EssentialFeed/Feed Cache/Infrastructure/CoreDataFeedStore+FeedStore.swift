//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 15/06/2024.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve() throws -> CachedFeed? {
        try ManagedCache.find(context: context).map {
            CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        let managedCache = try ManagedCache.findNewInstance(context: context)
        managedCache.timestamp = timestamp
        managedCache.feed = ManagedFeedImage.images(items: feed, context: context)
        try context.save()
    }
    
    public func deleteCachedFeed() throws {
        try ManagedCache.deleteCache(in: context)
    }
    
}
