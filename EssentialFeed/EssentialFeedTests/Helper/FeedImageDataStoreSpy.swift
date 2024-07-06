//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 14/06/2024.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }

    private(set) var receivedMessages = [Message]()
//    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var retrievalResult: Result<Data?,Error>?
//    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    private var insertionResult: Result<Void, Error>?


    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
//        insertionCompletions.append(completion)
        try insertionResult?.get()
    }

    func retrieve(dataForURL url: URL) throws -> Data?  {
        receivedMessages.append(.retrieve(dataFor: url))
//        /*retrievalCompletions*/.append(completion)
        return try retrievalResult?.get()
    }
    func completeRetrieval(with error: Error) {
        retrievalResult = .failure(error)
    }
//    func completeRetrieval(with error: Error, at index: Int = 0) {
//        retrievalCompletions[index](.failure(error))
//    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = (.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
//    func completeInsertion(with error: Error, at index: Int = 0) {
//        insertionCompletions[index](.failure(error))
//        insertionResult.
//    }
//    func completeInsertionSuccessfully(at index: Int = 0) {
//        insertionCompletions[index](.success(()))
//        }
}
