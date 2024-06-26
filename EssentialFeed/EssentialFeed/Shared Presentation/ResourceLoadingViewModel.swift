//
//  FeedViewModel.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation

public struct ResourceLoadingViewModel {
    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
    public  let isLoading: Bool
}
