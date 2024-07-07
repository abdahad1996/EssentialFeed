//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }
    
//    func test_save_requestsCacheDeletion() {
//        let (sut, store) = makeSUT()
//
//        sut.save(uniqueImages().models) { _ in }
//        
//        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
//    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)

        try? sut.save(uniqueImages().models)
 
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let feed = uniqueImages()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        try? sut.save(feed.models)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
//    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
//        let store = FeedStoreSpy()
//        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
//        
//        var receivedResults = [LocalFeedLoader.SaveResult]()
//        sut?.save(uniqueImages().models) { receivedResults.append($0) }
//        
//        sut = nil
//        store.completeDeletion(with: anyNSError())
//        
//        XCTAssertTrue(receivedResults.isEmpty)
//    }
//    
//    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
//        let store = FeedStoreSpy()
//        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
//        
//        var receivedResults = [LocalFeedLoader.SaveResult]()
//        sut?.save(uniqueImages().models) { receivedResults.append($0) }
//        
//        store.completeDeletionSuccessfully()
//        sut = nil
//        store.completeInsertion(with: anyNSError())
//        
//        XCTAssertTrue(receivedResults.isEmpty)
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
     func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
//        let exp = expectation(description: "Wait for save completion")
         action()
         var receivedError: NSError?
         do {
             try sut.save(uniqueImages().models)
         }catch   {
             receivedError = error as NSError?
         }
         XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)

//        var receivedError: Error?
//        sut.save(uniqueImages().models) { result in
//            if case let Result.failure(error) = result { receivedError = error }
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1.0)
//        
     }
    
}
