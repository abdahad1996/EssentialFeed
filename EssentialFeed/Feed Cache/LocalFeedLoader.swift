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
        self.store.insert(items.toLocal(),timeStamp: self.currentTimeStamp(), completion: {[weak self] error in
            guard let _ = self else{return}
            completion(error)
        })
    }
    
}

private extension Array where Element == FeedItem{
    func toLocal() -> [LocalFeedItem] {
        return map{LocalFeedItem(id: $0.id,description:$0.description,location:$0.location ,imageURL: $0.imageURL)}
    }
}

public struct LocalFeedItem:Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
