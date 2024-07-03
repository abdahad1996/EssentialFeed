//
//  Paginated.swift
//  EssentialFeed
//
//  Created by macbook abdul on 03/07/2024.
//

import Foundation
public struct Paginated<Items> {
    public typealias loadMoreCompletion = (Result<Self,Error>) -> Void
    public let items:[Items]
    public let loadMore:((@escaping loadMoreCompletion) -> Void)?
    
    public init(items: [Items], loadMore: ((loadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
