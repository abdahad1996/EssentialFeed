//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 15/04/2024.
//

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStoreTest:XCTestCase,FailableFeedStoreSpecs{
     
    override func setUp() {
        super.setUp()
        
        setUpEmptyStoreState()
    }
    
    
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreArtifact()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
        
    }
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    
   
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        insert((insertedItems,insertedTimeStamp),to:sut)
        expect(sut, toRetrieve: .found(feed: insertedItems, timeStamp: insertedTimeStamp))
    }
    
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        insert((insertedItems,insertedTimeStamp),to:sut)
        expect(sut, toRetrieve: .found(feed: insertedItems, timeStamp: insertedTimeStamp))

    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL)
        let retrievalError = anyError()
        
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve:.failure(retrievalError))
    }
    
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL)
        let retrievalError = anyError()
        
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(retrievalError))
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL)
        
        let firstItems = uniqueImages().local
        let firstTimeStamp = Date()
        
        insert((firstItems,firstTimeStamp),to:sut)

        
        let secondItems = uniqueImages().local
        let secondTimeStamp = Date()
        
        insert((secondItems,secondTimeStamp),to:sut)

        
        expect(sut, toRetrieve:.found(feed: secondItems, timeStamp: secondTimeStamp))
    }
    
    
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        let insertionError =  insert((insertedItems,insertedTimeStamp),to:sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert((uniqueImages().local,Date()),to:sut)

        let insertionError =  insert((uniqueImages().local,Date()),to:sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalidstoreurl")
        let sut = makeSUT(invalidStoreURL)
        
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        insert((insertedItems,insertedTimeStamp),to:sut)

        expect(sut, toRetrieve: .empty)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalidstoreurl")
        let sut = makeSUT(invalidStoreURL)
        
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        let insertionError = insert((insertedItems,insertedTimeStamp),to:sut)
        XCTAssertNotNil(insertionError,"Expected insertion to fail")

    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError =  deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL)
        
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        insert((insertedItems,insertedTimeStamp),to:sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        insert((insertedItems,insertedTimeStamp),to:sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")

    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionUrl = cachesDirectory()
        let sut = makeSUT(noDeletePermissionUrl)
        
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
        
    }
    
    func test_storeSideEffects_runSerially() {
        
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL)
        
        var expecations = [XCTestExpectation]()
        let op1 = expectation(description: "op1")
        sut.insert(uniqueImages().local, timeStamp: .init(), completion: { _ in
            expecations.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "op2")
        sut.deleteCacheFeed { _ in
            expecations.append(op2)
            op2.fulfill()
        }
        
        
        let op3 = expectation(description: "op3")
        sut.insert(uniqueImages().local, timeStamp: .init(), completion: { _ in
            expecations.append(op3)
            op3.fulfill()
        })
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(expecations,[op1,op2,op3], "Expected side-effects to run serially but operations finished in the wrong order")
    }
    
    private func makeSUT(_ storeURL:URL? = nil,file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of:self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    private func setUpEmptyStoreState() {
        deleteStoreArtifact()
    }
    
    private func undoStoreArtifact() {
        deleteStoreArtifact()
    }
    
    func deleteStoreArtifact() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
}
