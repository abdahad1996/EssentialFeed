//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedFeed?, Error>?

//    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
//        deletionCompletions.append(completion)
//        receivedMessages.append(.deleteCachedFeed)
//    }
    
    func deleteCachedFeed() throws {
        receivedMessages.append(.deleteCachedFeed)
        try deletionResult?.get()
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
//        deletionCompletions[index](.failure(error))
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
//        deletionCompletions[index](.success(()))
        deletionResult = .success(())

    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.insert(feed, timestamp))
        try insertionResult?.get()
    }

//    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
//        insertionCompletions.append(completion)
//        receivedMessages.append(.insert(feed, timestamp))
//    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
//        insertionCompletions[index](.failure(error))
        insertionResult = .failure(error)

    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
//        insertionCompletions[index](.success(()))
        insertionResult = .success(())
    }
    
    func retrieve() throws -> CachedFeed? {
        
        receivedMessages.append(.retrieve)
        return try retrievalResult?.get()
    }
    
//    func retrieve(completion: @escaping RetrievalCompletion) {
//        retrievalCompletions.append(completion)
//        receivedMessages.append(.retrieve)
//    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
//        retrievalCompletions[index](.failure(error))
        retrievalResult = .failure(error)

    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
//        retrievalCompletions[index](.success(.none))
        retrievalResult = .success(.none)

    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
//        retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
        retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))

    }
}
