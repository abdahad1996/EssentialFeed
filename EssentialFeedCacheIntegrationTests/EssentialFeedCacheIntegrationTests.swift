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
    
    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() throws{
        let sutToPerformSave = try makeSUT()
        let sutToPerformLoad = try makeSUT()
        let feed = uniqueImages().models
        
        
        save(feed, with: sutToPerformSave)
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() throws {
        let sutToPerformFirstSave = try makeSUT()
        let sutToPerformLastSave = try makeSUT()
        let sutToPerformLoad = try makeSUT()
        let firstFeed = uniqueImages().models
        let latestFeed = uniqueImages().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)
        
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
    
    private func makeSUT(file:StaticString = #file,line:UInt = #line) throws -> LocalFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
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
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedStore, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(items: feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
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
