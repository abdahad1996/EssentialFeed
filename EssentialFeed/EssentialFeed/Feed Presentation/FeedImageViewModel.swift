//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation

public struct FeedImageViewModel<Image>{
    public let location:String?
    public let description:String?
    public let image:Image?
    public let isLoading:Bool
    public let shouldRetry:Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
    
    public init(location: String?, description: String?, image: Image?, isLoading: Bool, shouldRetry: Bool) {
        self.location = location
        self.description = description
        self.image = image
        self.isLoading = isLoading
        self.shouldRetry = shouldRetry
    }
}
