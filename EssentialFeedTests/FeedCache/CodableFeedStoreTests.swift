//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 15/04/2024.
//

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache:Codable{
        let feed:[CodableFeedImage]
        let timeStamp:Date
        
        var localFeed:[LocalFeedImage]{
            feed.map{$0.local}
        }
    }
    
    private struct CodableFeedImage:Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local:LocalFeedImage{
            return LocalFeedImage(id: id,description: description,location: location, imageURL: url)
        }
    }
    let storeURL:URL
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    func retrieve(completion:@escaping FeedStore.retrieveCompletion){
        guard let data = try? Data(contentsOf: storeURL) else{
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
            
        }catch {
            completion(.failure(error))
        }
        
    }
    
    func insert(_ items:[LocalFeedImage],timeStamp:Date,completion:@escaping FeedStore.insertCompletion){
        
        do  {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(Cache(feed: items.map(CodableFeedImage.init),timeStamp: timeStamp))
            try encoded.write(to: storeURL)
            completion(nil)
        }catch{
            completion(error)
        }
         
    }
    
    func deleteCacheFeed(
        completion:@escaping FeedStore.deleteCompletion){
            completion(nil)
        }
}

class CodableFeedStoreTest:XCTestCase{
    
    override func setUp() {
        super.setUp()
        
        setUpEmptyStoreState()
    }
    
    
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreArtifact()
    }
    func test_retrieve_deliversEmptyCacheOnEmptyCache(){
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
        
    }
    
    func test_retrieveTwice_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
        let sut = makeSUT()
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        insert(sut, items: insertedItems, timeStamp: insertedTimeStamp)
        expect(sut, toRetrieve: .found(feed: insertedItems, timeStamp: insertedTimeStamp))
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        insert(sut, items: insertedItems, timeStamp: insertedTimeStamp)
        expect(sut, toRetrieveTwice: .found(feed: insertedItems, timeStamp: insertedTimeStamp))
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
      
        let firstInsertionError = insert(sut, items: firstItems, timeStamp: firstTimeStamp)
        XCTAssertNil(firstInsertionError,"expected feed to be inserted successfully")

        let secondItems = uniqueImages().local
        let secondTimeStamp = Date()
        
        let latestInsertionError = insert(sut, items: secondItems, timeStamp: secondTimeStamp)
        XCTAssertNil(firstInsertionError,"expected feed to be inserted successfully")
        
        expect(sut, toRetrieve:.found(feed: secondItems, timeStamp: secondTimeStamp))
    }
    
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalidstoreurl")
        let sut = makeSUT(invalidStoreURL)

        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        
        let insertionError = insert(sut, items: insertedItems, timeStamp: insertedTimeStamp)
        XCTAssertNotNil(insertionError,"expected feed to be inserted successfully")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
       let deletionError = delete(sut)
       XCTAssertNil(deletionError)
        
        expect(sut, toRetrieve: .empty)
    }
    
    
    private func makeSUT(_ storeURL:URL? = nil,file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut:CodableFeedStore,toRetrieveTwice expectedResult:RetrieveCacheFeedResult,file: StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)

        
    }
    
    @discardableResult
    private func insert(_ sut:CodableFeedStore,items:[LocalFeedImage],timeStamp:Date,file: StaticString = #file, line: UInt = #line) -> Error?{
        let exp = expectation(description: "wait for completion")
        
        var receivedError:Error?
        sut.insert(items, timeStamp: timeStamp) { errorResult in
            receivedError = errorResult
             exp.fulfill()
        }
        
        wait(for: [exp],timeout: 0.1)
        return receivedError

    }
    
    private func delete(_ sut:CodableFeedStore,file: StaticString = #file, line: UInt = #line) -> Error?{
        let exp = expectation(description: "wait for completion")
        
        var receivedError:Error?
        sut.deleteCacheFeed{ errorResult in
            receivedError = errorResult
             exp.fulfill()
        }
        
        wait(for: [exp],timeout: 0.1)
        return receivedError

    }
    private func expect(_ sut:CodableFeedStore,toRetrieve expectedResult:RetrieveCacheFeedResult,file: StaticString = #file, line: UInt = #line){
        
        let exp = expectation(description: "wait for completion")
        
        sut.retrieve{ retrievedResult in
            switch (retrievedResult,expectedResult) {
            case (.empty,.empty):
                break
            case (.failure,.failure):
                break
            case let (.found(receivedFeed,receivedTimeStamp),.found(feed: expectedFeed, timeStamp: expectedFeedTimeStamp)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                XCTAssertEqual(receivedTimeStamp, expectedFeedTimeStamp)

                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)

            }
            exp.fulfill()
        }
        
        
       
        wait(for: [exp],timeout: 0.1)

    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of:self)).store")
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
