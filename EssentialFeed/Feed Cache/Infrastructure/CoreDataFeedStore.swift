//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 02/05/2024.
//

import Foundation
import CoreData
 
public final class CoreDataFeedStore:FeedStore{
    
    private let container:NSPersistentContainer
    private let context: NSManagedObjectContext
    
    
    public init(storeURL:URL) throws{
        let bundle = Bundle(for: CoreDataFeedStore.self)
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
        
    }
    
     func perform(action:@escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform{action(context)}
         
    }
    
    
}
