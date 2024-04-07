//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by macbook abdul on 07/04/2024.
//

import Foundation


public class LocalFeedStore{
    private let store:FeedStore
    private let currentTimeStamp:() -> Date
    
    public typealias saveResult = Error?
    
    public init(store: FeedStore,currentTimeStamp:@escaping () -> Date) {
        self.store = store
        self.currentTimeStamp = currentTimeStamp
    }
    
    
    
    public func save(items:[FeedItem],completion:@escaping (saveResult) -> Void ){
        store.deleteCacheFeed {[weak self] error in
            guard let self = self else{return}
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            }
            else{
                cache(items: items, with: completion)
            }
        }
    }
    
    private func cache(items:[FeedItem],with completion:@escaping (saveResult) -> Void ) {
        self.store.insert(items,timeStamp: self.currentTimeStamp(), completion: {[weak self] error in
            guard let _ = self else{return}
            
            completion(error)
            
            
        })
    }
    
    
    
}
