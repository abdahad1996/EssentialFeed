//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation

public struct FeedImageViewModel{
    public let location:String?
    public let description:String?
   
    
    public var hasLocation: Bool {
        return location != nil
    }
    
    public init(location: String?, description: String?) {
        self.location = location
        self.description = description
    }
}
