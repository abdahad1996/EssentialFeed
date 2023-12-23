//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation

public enum HttpClientResult {
    case success(Data,HTTPURLResponse)
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
    
    public enum Result:Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    public func load(completion:@escaping (Result) -> Void){
    
        client.get(from: url, completion: {result in
            switch result {
            case .success(let data,_):
                if let root = try?  JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.items))
                }else{
                    completion(.failure(.invalidData))
                }
                
            case .failure(_):
                completion(.failure(.connectivity))
            }
            
        })
    }
}
private struct Root: Decodable {
    let items: [FeedItem]
}
