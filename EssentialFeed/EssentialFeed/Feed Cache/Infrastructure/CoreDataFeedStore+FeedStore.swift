//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 15/06/2024.
//

import Foundation

extension CoreDataFeedStore{
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
                    
            completion(Result{
                try ManagedCache.deleteCache(in: context)
            })
            
        }
    }
    
    public func insert(_ items: [LocalFeedImage], timestamp timeStamp: Date, completion: @escaping InsertionCompletion)  {
        performAsync { context in
            completion(Result{
                let cache = try ManagedCache.findNewInstance(context: context)
                cache.timestamp = timeStamp
                cache.feed = ManagedFeedImage.images(items: items, context: context)
                
                try context.save()
                
            })
        }
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion( Result {
                try ManagedCache.find(context: context).map{
                        return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                    }
                })
            }
        }
}
