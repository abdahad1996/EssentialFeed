//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation
public protocol HttpClient{
    func get(from url:URL,completion:@escaping (Error)->Void)
    
}

public class RemoteFeedLoader{
    
    private let url:URL
    private let client:HttpClient
    public enum Error:Swift.Error{
        case connectivity
    }
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion:@escaping (Error) -> Void = {_ in }){
        client.get(from: url, completion: {error in
            completion(.connectivity)
        })
    }
}
