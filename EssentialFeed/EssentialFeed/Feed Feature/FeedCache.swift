//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by macbook abdul on 17/06/2024.
//

import Foundation

public protocol FeedCache {
//    typealias Result = Swift.Result<Void, Error>
    
//    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
    func save(_ feed: [FeedImage]) throws
}
