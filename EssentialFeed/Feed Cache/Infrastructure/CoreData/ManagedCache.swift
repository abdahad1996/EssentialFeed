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



