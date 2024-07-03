//
//  Paginated.swift
//  EssentialFeed
//
//  Created by macbook abdul on 03/07/2024.
//

import Foundation
public struct Paginated<Item> {
    public typealias loadMoreCompletion = (Result<Self,Error>) -> Void
    public let items:[Item]
    public let loadMore:((@escaping loadMoreCompletion) -> Void)?
    
    public init(items: [Item], loadMore: ((@escaping loadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
