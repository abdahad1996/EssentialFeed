//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by macbook abdul on 02/05/2024.
//

import Foundation
import CoreData

@objc(ManagedCache)
class ManagedCache:NSManagedObject{
    @NSManaged var timestamp:Date
    @NSManaged var feed:NSOrderedSet
    
}
extension ManagedCache {
    var localFeed:[LocalFeedImage] {
        return feed.compactMap{($0 as? ManagedFeedImage)}.map{$0.local}
    }
    
    static func find(context:NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func findNewInstance(context:NSManagedObjectContext) throws -> ManagedCache {
        try deleteCache(in: context)
        return ManagedCache(context: context)
    }
    
    static func deleteCache(in context: NSManagedObjectContext) throws {
        try find(context: context).map(context.delete).map(context.save)
        }
    
}


