//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?,Error>
    func retrieve(dataForURL url: URL,completion:@escaping (Result) -> Void )
    
}
class LocalFeedImageDataLoader {
    
    let store:FeedImageDataStore
    init(store:FeedImageDataStore){
        self.store = store
    }
    enum Error:Swift.Error{
        case failed
    }
    struct Task:FeedImageDataLoaderTask{
        func cancel() {
            
        }
    }
    func loadImageData(from url: URL,completion:@escaping(FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(Error.failed))
            default:break
            }
            
        }
        return Task()
    }
}
class LocalFeedImageDataLoaderTests:XCTestCase{
    
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL(){
        let (sut,store) = makeSUT()
        let url = anyUrl()
        
        sut.loadImageData(from: url) {_ in}
        
        XCTAssertEqual(store.messages,[.retreival(url: url)])

    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        
        let (sut,store) = makeSUT()
        let url = anyUrl()
        let anyError = anyError()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyError
            store.complete(with: retrievalError)
          })

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
        var completions = [(FeedImageDataStore.Result) -> Void]()
        enum Message:Equatable {
            case retreival(url:URL)
        }
        
        
        init() {}
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            messages.append(.retreival(url: url))
            completions.append(completion)
        }
        
        func complete(with error:Error,at index:Int = 0){
            completions[index](.failure(error))
        }
        
       
    }
    
}
