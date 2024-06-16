//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 17.12.23.
//

import Foundation

public struct FeedImage:Hashable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = imageURL
    }
}

