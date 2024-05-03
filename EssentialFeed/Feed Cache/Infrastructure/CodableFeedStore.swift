//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 21/04/2024.
//

import Foundation

public class CodableFeedStore:FeedStore {
    private struct Cache:Codable{
        let feed:[CodableFeedImage]
        let timeStamp:Date
        
        var localFeed:[LocalFeedImage]{
            feed.map{$0.local}
        }
    }
    
    private struct CodableFeedImage:Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local:LocalFeedImage{
            return LocalFeedImage(id: id,description: description,location: location, imageURL: url)
        }
    }
    let storeURL:URL
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    
    public func retrieve(completion:@escaping retrieveCompletion){
        queue.async { [storeURL] in
            guard let data = try? Data(contentsOf: storeURL) else{
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
                
            }catch {
                completion(.failure(error))
            }
        }
        
        
    }
    
    public func insert(_ items:[LocalFeedImage],timeStamp:Date,completion:@escaping insertCompletion){
        queue.async { [storeURL] in
            do  {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(Cache(feed: items.map(CodableFeedImage.init),timeStamp: timeStamp))
                try encoded.write(to: storeURL)
                completion(nil)
            }catch{
                completion(error)
            }
            
        }
         
    }
    
    public func deleteCacheFeed(
        completion:@escaping deleteCompletion){
            let storeURL = self.storeURL

            queue.async {
                guard FileManager.default.fileExists(atPath: storeURL.path) else{
                    return completion(nil)
                }
                do {
                    try FileManager.default.removeItem(at: storeURL)
                    completion(nil)
                }catch {
                    completion(error)
                }
                
            }
        }
}
