//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 07/04/2024.
//

import Foundation

public protocol FeedStore{
    typealias deleteCompletion = (Error?) -> Void
    typealias insertCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion:@escaping (Error?) -> Void)
    func insert(_ items:[FeedItem],timeStamp:Date,completion:@escaping (Error?) -> Void)
}
