//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by macbook abdul on 03/05/2024.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
         setupEmptyStoreState()
    }
    override func tearDown()  {
        super.tearDown()
         undoStoreArtifact()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for load completion")
        sut.load { result in
            switch result {
            case .success(let imageFeed):
                XCTAssertEqual(imageFeed, [],"Expected empty feed")
            case .failure(let error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp],timeout: 1)
    }
    private func setupEmptyStoreState() {
        deleteStoreArtifact()
    }
    
    private func undoStoreArtifact() {
       deleteStoreArtifact()
    }
    
    private func deleteStoreArtifact() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> LocalFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedStore(store: store, currentTimeStamp: Date.init)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return sut

    }

    private func testSpecificStoreURL() -> URL{
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
