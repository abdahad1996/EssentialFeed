//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by macbook abdul on 08/04/2024.
//

import Foundation

public struct LocalFeedImage:Equatable {
    
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