//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 08/04/2024.
//

import Foundation
import EssentialFeed
// Mark:Helper
class FeedStoreSpy:FeedStore{
    private var deletionCompletion = [deleteCompletion]()
    private var insertionCompletion = [insertCompletion]()
    private var retrievalCompletion = [retrieveCompletion]()
    private(set) var receivedMessages = [ReceivedMessages]()
    
    enum ReceivedMessages:Equatable{
        case deleteCacheFeed
        case insert(items:[LocalFeedImage],timeStamp:Date)
        case retrieve
    }
    
     func deleteCacheFeed(completion:@escaping deleteCompletion){
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error:Error,at index:Int = 0){
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessFully(at index:Int = 0){
        deletionCompletion[index](nil)
    }
    
    func completeInsertion(with error:Error, at index:Int = 0){
        insertionCompletion[index](error)
    }
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletion[index](nil)
    }
    
    func insert(_ items:[LocalFeedImage],timeStamp:Date,completion:@escaping insertCompletion){
        receivedMessages.append(.insert(items: items, timeStamp: timeStamp))
        insertionCompletion.append(completion)
    }
     
    
    func retrieve(completion:@escaping retrieveCompletion) {
        receivedMessages.append(.retrieve)
        retrievalCompletion.append(completion)
    }
    
    func completeRetrieval(with error:Error, at index:Int = 0){
        retrievalCompletion[index](error)
    }
     
}
