//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 02/05/2024.
//

import Foundation
import CoreData
 
extension CoreDataFeedStore:FeedImageDataStore{
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
                    completion(Result {
                        return try ManagedFeedImage.first(with: url, in: context)?.data
                    })
                }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
        perform { context in
            completion(Result{
                
                guard let image = try? ManagedFeedImage.first(with: url, in: context) else { return }
                
                image.data = data
                try? context.save()
            })
                }
    }
}
