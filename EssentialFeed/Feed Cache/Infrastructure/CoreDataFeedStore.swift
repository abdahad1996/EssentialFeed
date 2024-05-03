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
    let context: NSManagedObjectContext
    
    
    public init(storeURL:URL,bundle:Bundle = .main) throws{
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
        
    }
    
    private func perform(action:@escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform{action(context)}
         
    }
    public func deleteCacheFeed(completion: @escaping deleteCompletion) {
        perform { context in
            do{
                try ManagedCache.find(context: context).map{context.delete($0)}.map(context.save)
                completion(nil)
            }catch {
                completion(error)
            }
            
        }
    }
    
    public func insert(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping insertCompletion)  {
        perform { context in
            do {
                let cache = try ManagedCache.findNewInstance(context: context)
                cache.timestamp = timeStamp
                cache.feed = ManagedFeedImage.images(items: items, context: context)
                
                try context.save()
                completion(nil)
                
                
            }catch {
                completion(error)
            }
        }
        
    }
    public func retrieve(completion: @escaping retrieveCompletion) {
        perform { context in
                do {
                    if let cache = try ManagedCache.find(context: context) {
                        completion(.found(
                            feed: cache.localFeed,
                            timeStamp: cache.timestamp))
                    } else {
                        completion(.empty)
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
}
