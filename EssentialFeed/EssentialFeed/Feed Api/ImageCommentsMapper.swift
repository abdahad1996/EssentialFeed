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
        guard isOK(response),
        let root = try? JSONDecoder().decode(Root.self, from: data)
        else{
             throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    private static func isOK(_ response:HTTPURLResponse) -> Bool{
        return (200...299).contains(response.statusCode)
    }
}

