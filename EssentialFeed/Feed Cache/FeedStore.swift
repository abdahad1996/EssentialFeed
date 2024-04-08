//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 07/04/2024.
//

import Foundation

public protocol FeedStore{
    typealias deleteCompletion = (LocalFeedStore.saveResult) -> Void
    typealias insertCompletion = (LocalFeedStore.saveResult) -> Void
    typealias retrieveCompletion = (LocalFeedStore.loadResult) -> Void
    
    func deleteCacheFeed(
        completion:@escaping deleteCompletion)
    func insert(_ items:[LocalFeedImage],timeStamp:Date,completion:@escaping insertCompletion)
    
    func retrieve(completion:@escaping retrieveCompletion)
}
