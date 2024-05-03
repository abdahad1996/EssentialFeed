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
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
            let sutToPerformSave = makeSUT()
            let sutToPerformLoad = makeSUT()
            let feed = uniqueImages().models

            let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(items: feed) { saveError in
                XCTAssertNil(saveError, "Expected to save feed successfully")
                saveExp.fulfill()
            }
            wait(for: [saveExp], timeout: 1.0)

            let loadExp = expectation(description: "Wait for load completion")
            sutToPerformLoad.load { loadResult in
                switch loadResult {
                case let .success(imageFeed):
                    XCTAssertEqual(imageFeed, feed)

                case let .failure(error):
                    XCTFail("Expected successful feed result, got \(error) instead")
                }

                loadExp.fulfill()
            }
            wait(for: [loadExp], timeout: 1.0)
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
