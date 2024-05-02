//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 02/05/2024.
//

import Foundation
import CoreData

private extension NSPersistentContainer{
    enum loadingError:Error{
        case modelNotFound
        case failedToLoadPersistentStores(Error)
    }
    static func load(modelName name:String,url:URL,in bundle:Bundle) throws -> NSPersistentContainer{
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else{
            throw loadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError:Error?
        container.loadPersistentStores{loadError = $1}
        try loadError.map{throw loadingError.failedToLoadPersistentStores($0)}
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name:String,in bundle: Bundle) ->NSManagedObjectModel?{
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap{NSManagedObjectModel(contentsOf: $0)}
        
    }
}

public class CoreDataFeedStore:FeedStore{
    private let container:NSPersistentContainer
    let context: NSManagedObjectContext
    
    
    public init(storeURL:URL,bundle:Bundle = .main) throws{
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
        
    }
    public func deleteCacheFeed(completion: @escaping deleteCompletion) {
//        container
    }
    
    public func insert(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping insertCompletion)  {
        let context = self.context
        
        context.perform {
            do {
                let cache = ManagedCache(context:  context)
                cache.timestamp = timeStamp
                cache.feed = NSOrderedSet(array: items.map({ localFeed in
                    let managedFeed = ManagedFeedImage(context: context)
                    managedFeed.id = localFeed.id
                    managedFeed.imageDescription = localFeed.description
                    managedFeed.location = localFeed.location
                    managedFeed.url = localFeed.url
                    return managedFeed
                }))
                
                try context.save()
                completion(nil)
                
                
            }catch {
                completion(error)
            }
        }
        
    }
     
    public func retrieve(completion: @escaping retrieveCompletion) {
             let context = self.context
            context.perform {
                do {
                    let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                    request.returnsObjectsAsFaults = false
                    if let cache = try context.fetch(request).first {
                        completion(.found(
                            feed: cache.feed
                                .compactMap { ($0 as? ManagedFeedImage) }
                                .map {
                                    LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, imageURL: $0.url)
                                },
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
