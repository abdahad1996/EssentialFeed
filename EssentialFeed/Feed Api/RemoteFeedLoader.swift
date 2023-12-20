//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation

public enum HttpClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient{
    func get(from url:URL,completion:@escaping (HttpClientResult)->Void)
    
}

public class RemoteFeedLoader{
    
    private let url:URL
    private let client:HttpClient
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    public func load(completion:@escaping (Error) -> Void){
    
        client.get(from: url, completion: {result in
            switch result {
            case .success(_):
                completion(.invalidData)
            case .failure(_):
                completion(.connectivity)
            }
            
        })
    }
}
