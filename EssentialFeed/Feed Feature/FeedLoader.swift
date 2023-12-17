//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 17.12.23.
//

import Foundation

enum Result {
    case success([FeedItem])
    case failure(Error)
}
protocol FeedLoader {
    func load(completion:@escaping(Result) -> Void)
}
