//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 15/06/2024.
//

import Foundation

extension CoreDataFeedStore{
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
                    
            completion(Result{
                try ManagedCache.find(context: context).map{context.delete($0)}.map(context.save)
            })
            
        }
    }
    
    public func insert(_ items: [LocalFeedImage], timestamp timeStamp: Date, completion: @escaping InsertionCompletion)  {
        perform { context in
            completion(Result{
                let cache = try ManagedCache.findNewInstance(context: context)
                cache.timestamp = timeStamp
                cache.feed = ManagedFeedImage.images(items: items, context: context)
                
                try context.save()
                
            })
        }
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion( Result {
                try ManagedCache.find(context: context).map{
                        return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                    }
                })
            }
        }
}
