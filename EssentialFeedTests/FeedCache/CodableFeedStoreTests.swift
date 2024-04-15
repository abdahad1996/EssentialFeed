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
    struct Cache:Codable{
        let feed:[LocalFeedImage]
        let timeStamp:Date
    }
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    func retrieve(completion:@escaping FeedStore.retrieveCompletion){
        guard let data = try? Data(contentsOf: storeURL) else{
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timeStamp: cache.timeStamp))
       
    }
    
    func insert(_ items:[LocalFeedImage],timeStamp:Date,completion:@escaping FeedStore.insertCompletion){
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: items,timeStamp: timeStamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTest:XCTestCase{
    
    override func setUp() {
            super.setUp()

            let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
            try? FileManager.default.removeItem(at: storeURL)
        }

        override func tearDown() {
            super.tearDown()

            let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
            try? FileManager.default.removeItem(at: storeURL)
        }
    func test_retrieve_deliversEmptyCacheOnEmptyCache(){
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for completion")
        sut.retrieve{ result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expected empty cache but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp],timeout: 0.1)
    }
    
    func test_retrieveTwice_hasNoSideEffectOnEmptyCache(){
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for completion")
        sut.retrieve{ firstResult in
            sut.retrieve{ secondResult in
                switch (firstResult,secondResult) {
                case (.empty,.empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")

                }
                exp.fulfill()
            }
            
        }
        
        wait(for: [exp],timeout: 0.1)
    }
    
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        
        let sut = CodableFeedStore()
        let insertedItems = uniqueImages().local
        let insertedTimeStamp = Date()
        let exp = expectation(description: "wait for completion")
        
        sut.insert(insertedItems,timeStamp: insertedTimeStamp){ error in
            XCTAssertNil(error,"expected feed to be inserted successfully")
            sut.retrieve { retrievedResult in
                switch retrievedResult {
                case let .found(retrievedItems,retrievedTimeStamp):
                    XCTAssertEqual(insertedItems, retrievedItems)
                    XCTAssertEqual(insertedTimeStamp, retrievedTimeStamp)

                default:
                    XCTFail("expected found result with \(insertedItems), \(insertedTimeStamp) but got \(retrievedResult) instead")
                    
                }
            }
            exp.fulfill()
        }
//        sut.insert{ firstResult in
//            sut.retrieve{ secondResult in
//                switch (firstResult,secondResult) {
//                case (.empty,.empty):
//                    break
//                default:
//                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
//
//                }
//                exp.fulfill()
//            }
//            
//        }
        
        wait(for: [exp],timeout: 0.1)
    }
    
}