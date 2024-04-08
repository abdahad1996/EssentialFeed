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
    
    func deleteCacheFeed(completion:@escaping (Error?) -> Void)
    func insert(_ items:[LocalFeedImage],timeStamp:Date,completion:@escaping (Error?) -> Void)
}
