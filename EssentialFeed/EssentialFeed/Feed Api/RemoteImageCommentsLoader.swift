//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation

public class RemoteImageCommentsLoader{
    
    private let url:URL
    private let client:HTTPClient
    
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment],Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
   
    
    public func load(completion:@escaping (Result) -> Void){
    
        client.get(from: url, completion: {[weak self] result in
            guard self != nil else{return}
            switch result {
            case .success((let data,let response)):
                completion(RemoteImageCommentsLoader.map(data, response))
             
            case .failure(_):
                completion(.failure(RemoteImageCommentsLoader.Error.connectivity))
            }
            
        })
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items =  try ImageCommentsMapper.map(data, response)
            return .success(items)
        }
        catch (_) {
          return .failure(RemoteImageCommentsLoader.Error.invalidData)
        }
     }
   
}

