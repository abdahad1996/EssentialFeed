//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation
import XCTest
import EssentialFeed


class CacheFeedImageDataUseCaseTests:XCTestCase{
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL(){
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyUrl()
        
        sut.save(data, for: url, completion: {_ in})
        XCTAssertEqual(store.receivedMessages,[.insert(data: data, for: url)])
        
    }
    
    func test_saveImageDataFromURL_failsOnStoreInsertionError()
    {
        let (sut, store) = makeSUT()
                expect(sut, toCompleteWith: failed(), when: {
                    let insertionError = anyError()
                    store.completeInsertion(with: insertionError)
                })
        
    }
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
            let store = FeedImageDataStoreSpy()
            let sut = LocalFeedImageDataLoader(store: store)
            trackForMemoryLeaks(store, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, store)
        }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
            return .failure(LocalFeedImageDataLoader.SaveError.failed)
        }

        private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            sut.save(anyData(), for: anyUrl()) { receivedResult in
                switch (receivedResult, expectedResult) {
                case (.success, .success):
                    break

                case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
                      .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
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
