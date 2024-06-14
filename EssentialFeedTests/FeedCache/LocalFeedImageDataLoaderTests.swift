//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

 


class LocalFeedImageDataLoaderTests:XCTestCase{
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL(){
        let (sut,store) = makeSUT()
        let url = anyUrl()
        
        _ = sut.loadImageData(from: url) {_ in}
        XCTAssertEqual(store.messages,[.retreival(url: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        
        let (sut,store) = makeSUT()
        let anyError = anyError()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyError
            store.complete(with: retrievalError)
          })

    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.complete(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith:.success(data) , when: {
            store.complete(with: data)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        
        
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyUrl()) { received.append($0) }
        
        task.cancel()
        store.complete(with: foundData)
        store.complete(with: .none)
        store.complete(with: anyError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
        
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        
        let store = StoreSpy()
        var sut:LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        let foundData = anyData()


        var received = [FeedImageDataLoader.Result]()
        let task = sut?.loadImageData(from: anyUrl()) { received.append($0) }
        
        
        sut = nil
        store.complete(with: foundData)
        XCTAssertTrue(received.isEmpty, "Expected no received results after nil task")
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL(){
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyUrl()
        
        sut.save(data, for: url, completion: {_ in})
//        expect(sut, toCompleteWith:.success(data) , when: {
//            store.complete(with: data)
//        })
        
        XCTAssertEqual(store.messages,[.saver(url: url, data: data)])
        
        
    }
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
            let store = StoreSpy()
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
    
    
    private class StoreSpy:FeedImageDataStore {
        
        
        var messages = [Message]()
        var retrievalCompletions = [(FeedImageDataStore.Result) -> Void]()
        var saveCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
        
        enum Message:Equatable {
            case retreival(url:URL)
            case saver(url:URL,data:Data)
        }
        
        init() {}
        
        //MARK: RETRIEVAL
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            messages.append(.retreival(url: url))
            retrievalCompletions.append(completion)
        }
        
        func complete(with error:Error,at index:Int = 0){
            retrievalCompletions[index](.failure(error))
        }
        
        func complete(with data:Data?,at index:Int = 0){
            retrievalCompletions[index](.success(data))

        }
        
        //MARK: SAVE
        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            saveCompletions.append(completion)
            messages.append(.saver(url: url, data: data))
        }
        
    }
    
     
    
}
