//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 05/06/2024.
//

import Foundation

struct FeedImageViewModel<Image>{
    let location:String?
    let description:String?
    let image:Image?
    let isLoading:Bool
    let shouldRetry:Bool
    
    var hasLocation: Bool {
        return location != nil
    }
    
}
