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
    
    func retrieve(completion:@escaping FeedStore.retrieveCompletion){
        completion(.empty)
    }
}

class CodableFeedStoreTest:XCTestCase{
    
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
    
}
