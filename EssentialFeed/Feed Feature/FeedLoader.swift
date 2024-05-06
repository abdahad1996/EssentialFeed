//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 17.12.23.
//

import Foundation


 
public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion:@escaping(FeedLoader.Result) -> Void)
}
