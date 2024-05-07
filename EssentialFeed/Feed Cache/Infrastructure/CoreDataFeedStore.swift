//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 02/05/2024.
//

import Foundation
import CoreData
 
public class CoreDataFeedStore:FeedStore{
    
    private let container:NSPersistentContainer
    private let context: NSManagedObjectContext
    
    
    public init(storeURL:URL,bundle:Bundle = .main) throws{
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
        
    }
    
    private func perform(action:@escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform{action(context)}
         
    }
    
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
