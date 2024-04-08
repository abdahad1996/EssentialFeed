//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 23.12.23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}

internal class FeedItemsMapper{
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static var OK_200: Int { return 200 }

    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
        let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
             throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

