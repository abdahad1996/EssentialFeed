//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation

public class RemoteFeedLoader{
    
    private let url:URL
    private let client:HttpClient
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public enum Result:Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
   
    
    
    
    public func load(completion:@escaping (Result) -> Void){
    
        client.get(from: url, completion: {[weak self] result in
            guard let self = self else{return}
            switch result {
            case .success(let data,let response):
                completion(FeedItemsMapper.map(data, response))
             
            case .failure(_):
                completion(.failure(.connectivity))
            }
            
        })
    }
   
}
