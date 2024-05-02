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
    static func load(modelName name:String,in bundle:Bundle) throws -> NSPersistentContainer{
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else{
            throw loadingError.modelNotFound
        }
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
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
    public init(bundle:Bundle = .main) throws{
        container = try NSPersistentContainer.load(modelName: "FeedStore", in: bundle)

    }
    public func deleteCacheFeed(completion: @escaping deleteCompletion) {
         container
    }
    
    public func insert(_ items: [EssentialFeed.LocalFeedImage], timeStamp: Date, completion: @escaping insertCompletion) {
         
    }
    
    public func retrieve(completion: @escaping retrieveCompletion) {
        completion(.empty)
    }
}
