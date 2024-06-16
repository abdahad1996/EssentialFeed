//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by macbook abdul on 03/05/2024.
//

import Foundation
import CoreData

 extension NSPersistentContainer{
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

 extension NSManagedObjectModel {
    static func with(name:String,in bundle: Bundle) ->NSManagedObjectModel?{
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap{NSManagedObjectModel(contentsOf: $0)}
        
    }
}
