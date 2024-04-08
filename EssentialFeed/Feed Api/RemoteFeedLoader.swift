//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation

public class RemoteFeedLoader:FeedLoader{
    
    private let url:URL
    private let client:HTTPClient
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
   
    
    public func load(completion:@escaping (Result) -> Void){
    
        client.get(from: url, completion: {[weak self] result in
            guard self != nil else{return}
            switch result {
            case .success(let data,let response):
                completion(RemoteFeedLoader.map(data, response))
             
            case .failure(_):
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
            
        })
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let remoteFeedItems =  try FeedItemsMapper.map(data, response)
            return .success(remoteFeedItems.toModels())
        }
        catch (_) {
          return .failure(RemoteFeedLoader.Error.invalidData)
        }
     }
   
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map{FeedImage(id: $0.id, description: $0.description,location: $0.location,imageURL: $0.image)}
    }
}
