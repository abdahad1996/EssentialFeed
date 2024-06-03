//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 23.12.23.
//

import Foundation


final class FeedItemsMapper{
    private init(){}
    
     private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static let OK_200: Int =  200

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
        let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
             throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

