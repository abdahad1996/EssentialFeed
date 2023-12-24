//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 17.12.23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    
    func load(completion:@escaping(LoadFeedResult) -> Void)
}
