//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 17.12.23.
//

import Foundation

public struct FeedItem:Equatable,Decodable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
