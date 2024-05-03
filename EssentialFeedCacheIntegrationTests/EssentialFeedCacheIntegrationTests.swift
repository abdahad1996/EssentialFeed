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
        
        expect(sut, toLoad: [])
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

           expect(sutToPerformLoad, toLoad: feed)
        }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
            let sutToPerformFirstSave = makeSUT()
            let sutToPerformLastSave = makeSUT()
            let sutToPerformLoad = makeSUT()
            let firstFeed = uniqueImages().models
            let latestFeed = uniqueImages().models

            let saveExp1 = expectation(description: "Wait for save completion")
        sutToPerformFirstSave.save(items: firstFeed) { saveError in
                XCTAssertNil(saveError, "Expected to save feed successfully")
                saveExp1.fulfill()
            }
            wait(for: [saveExp1], timeout: 1.0)

            let saveExp2 = expectation(description: "Wait for save completion")
        sutToPerformLastSave.save(items: latestFeed) { saveError in
                XCTAssertNil(saveError, "Expected to save feed successfully")
                saveExp2.fulfill()
            }
            wait(for: [saveExp2], timeout: 1.0)

            expect(sutToPerformLoad, toLoad: latestFeed)
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
    private func expect(_ sut: LocalFeedStore, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")
            sut.load { result in
                switch result {
                case let .success(loadedFeed):
                    XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)

                case let .failure(error):
                    XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
                }

                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
}
