//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 23.12.23.
//

import Foundation

final class ImageCommentsMapper{
    private init(){}
    
     private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
        let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
             throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

