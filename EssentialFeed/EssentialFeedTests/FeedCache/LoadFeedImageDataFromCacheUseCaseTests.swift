//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation
import XCTest
import EssentialFeed


class LoadFeedImageDataFromCacheUseCaseTests:XCTestCase{
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL(){
        let (sut,store) = makeSUT()
        let url = anyUrl()
        
        _ = sut.loadImageData(from: url) {_ in}
        XCTAssertEqual(store.receivedMessages,[.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        
        let (sut,store) = makeSUT()
        let anyError = anyError()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyError
            store.completeRetrieval(with: retrievalError)
          })

    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith:.success(data) , when: {
            store.completeRetrieval(with: data)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        
        
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyUrl()) { received.append($0) }
        
        task.cancel()
        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
        
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        
        let store = FeedImageDataStoreSpy()
        var sut:LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        let foundData = anyData()


        var received = [FeedImageDataLoader.Result]()
        let task = sut?.loadImageData(from: anyUrl()) { received.append($0) }
        
        
        sut = nil
        store.completeRetrieval(with: foundData, at: 0)
        XCTAssertTrue(received.isEmpty, "Expected no received results after nil task")
    }
    
   
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
            let store = FeedImageDataStoreSpy()
            let sut = LocalFeedImageDataLoader(store: store)
            trackForMemoryLeaks(store, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, store)
        }
    
    func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
            return .failure(LocalFeedImageDataLoader.Error.notFound)
        }
   

        private func never(file: StaticString = #file, line: UInt = #line) {
            XCTFail("Expected no no invocations", file: file, line: line)
        }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            _ = sut.loadImageData(from: anyUrl()) { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)

                case (.failure(let receivedError as LocalFeedImageDataLoader.Error),
                      .failure(let expectedError as LocalFeedImageDataLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }

                exp.fulfill()
            }

            action()
            wait(for: [exp], timeout: 1.0)
        }
    
     
    
}
