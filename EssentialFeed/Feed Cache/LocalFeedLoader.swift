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
    public typealias loadResult = LoadFeedResult

    public init(store: FeedStore,currentTimeStamp:@escaping () -> Date) {
        self.store = store
        self.currentTimeStamp = currentTimeStamp
    }
    
    public func load(completion: @escaping (loadResult)-> Void){
        store.retrieve { [unowned self] retrieveResult in
            switch retrieveResult {
            case .empty,.found:
                completion(.success([]))
            
            case let .found(localImages,timeStamp) where self.validateCache(timeStamp):
                completion(.success(localImages.toDomain()))

            
            case let .failure(error):
                completion(.failure(error))
            }
             
        }
    }
    
    private func validateCache(_ timeStamp:Date) -> Bool{
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timeStamp) else {
            return false
        }
        print(currentTimeStamp() < maxCacheAge)
        print(currentTimeStamp())
        print(maxCacheAge)

        return currentTimeStamp() < maxCacheAge
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
        self.store.insert(items.toLocal(),timeStamp: self.currentTimeStamp(), completion: {[weak self] error in
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

