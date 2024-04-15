//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by macbook abdul on 07/04/2024.
//

import Foundation

public class LocalFeedStore{
    private let store:FeedStore

    public typealias saveResult = Error?
    public typealias loadResult = LoadFeedResult
    let currentTimeStamp:() -> Date


    public init(store: FeedStore,currentTimeStamp: @escaping () -> Date) {
        self.store = store
        self.currentTimeStamp = currentTimeStamp
    }
    
    public func load(completion: @escaping (loadResult)-> Void){
        store.retrieve { [weak self] retrieveResult in
            guard let self = self else {return}
            switch retrieveResult {
            case let .failure(error):
                store.deleteCacheFeed{_ in}
                completion(.failure(error))
                
            case let .found(localImages,timeStamp) where CachePolicy.validateCache(timeStamp, against: currentTimeStamp()):
                completion(.success(localImages.toDomain()))

            case .empty:
                completion(.success([]))
                
            case .found:
                store.deleteCacheFeed{_ in}
                completion(.success([]))
            
            }
             
        }
    }
    
   
    public func save(items:[FeedImage],completion:@escaping (saveResult) -> Void ){
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
    
    
    private func cache(items:[FeedImage],with completion:@escaping (saveResult) -> Void ) {
        self.store.insert(items.toLocal(),timeStamp: currentTimeStamp(), completion: {[weak self] error in
            guard let _ = self else{return}
            completion(error)
        })
    }
    
}

private extension Array where Element == FeedImage{
    func toLocal() -> [LocalFeedImage] {
        return map{LocalFeedImage(id: $0.id,description:$0.description,location:$0.location ,imageURL: $0.url)}
    }
}

private extension Array where Element == LocalFeedImage{
    func toDomain() -> [FeedImage] {
        return map{FeedImage(id: $0.id, description: $0.description, location:  $0.location, imageURL: $0.url)}
    }
}

