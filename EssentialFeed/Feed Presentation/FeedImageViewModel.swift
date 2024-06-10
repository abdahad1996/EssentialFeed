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
    
    var hasLocation: Bool {
        return location != nil
    }
    
}
