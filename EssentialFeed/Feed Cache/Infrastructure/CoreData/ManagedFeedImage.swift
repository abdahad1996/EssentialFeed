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
    @NSManaged var cache:ManagedCache

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
     
    var local:LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription,location: location,imageURL: url)
    }

}
//extension Managedfeed {
//    internal static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
//        return NSOrderedSet(array: localFeed.map { local in
//            let managed = ManagedFeedImage(context: context)
//            managed.id = local.id
//            managed.imageDescription = local.description
//            managed.location = local.location
//            managed.url = local.url
//            return managed
//        })
//    }
//
//    internal var local: LocalFeedImage {
//        return LocalFeedImage(id: id , description: imageDescription, location: location, imageURL: url!)
//    }
//}
