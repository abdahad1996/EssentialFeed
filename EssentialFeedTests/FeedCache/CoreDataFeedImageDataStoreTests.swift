//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 14/06/2024.
//

import Foundation
import XCTest
import EssentialFeed


class CoreDataFeedImageDataStoreTests:XCTestCase{
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
            let sut = makeSUT()

            expect(sut, toCompleteRetrievalWith: notFound(), for: anyUrl())
        }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!

        
        let nonMatchingURL = URL(string: "http://another-url.com")!
        insert(anyData(), for: url, into: sut)
        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL(){
        let sut = makeSUT()
        let matchingURL = URL(string: "http://a-url.com")!
        let storedData = anyData()

 
        insert(storedData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
        
    }
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let matchingURL = URL(string: "http://a-url.com")!
        let firstStoredData = Data("first".utf8)
        let secondStoredData = Data("second".utf8)

 
        insert(firstStoredData, for: matchingURL, into: sut)
        insert(secondStoredData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(secondStoredData), for: matchingURL)
        
        
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
            let storeBundle = Bundle(for: CoreDataFeedStore.self)
            let storeURL = URL(fileURLWithPath: "/dev/null")
            let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
            trackForMemoryLeaks(sut, file: file, line: line)
            return sut
        }

        private func notFound() -> FeedImageDataStore.RetrievalResult {
            return .success(.none)
        }
    private func found(_ data:Data) -> FeedImageDataStore.RetrievalResult{
        return .success(data)
    }

        private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")
            sut.retrieve(dataForURL: url) { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success( receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)

                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
            sut.insert([image], timestamp: Date()) { result in
                switch result {
                case let .failure(error):
                    XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)

                case .success:
                    sut.insert(data, for: url) { result in
                        if case let Result.failure(error) = result {
                            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                        }
                    }
                }
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", imageURL: url)
        }
}