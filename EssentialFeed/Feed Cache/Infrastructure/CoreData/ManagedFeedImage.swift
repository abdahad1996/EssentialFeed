//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by macbook abdul on 02/05/2024.
//

import Foundation
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage:NSManagedObject{
    @NSManaged var id:UUID
    @NSManaged var imageDescription:String?
    @NSManaged var location:String?
    @NSManaged var url:URL
    @NSManaged var data: Data?
    @NSManaged var cache:ManagedCache
    
}
extension ManagedFeedImage {
    static func images(items:[LocalFeedImage],context:NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: items.map({ localFeed in
            let managedFeed = ManagedFeedImage(context: context)
            managedFeed.id = localFeed.id
            managedFeed.imageDescription = localFeed.description
            managedFeed.location = localFeed.location
            managedFeed.url = localFeed.url
            return managedFeed
        }))
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
            let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
            request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            return try context.fetch(request).first
        }
    
    var local:LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription,location: location,imageURL: url)
    }

}
