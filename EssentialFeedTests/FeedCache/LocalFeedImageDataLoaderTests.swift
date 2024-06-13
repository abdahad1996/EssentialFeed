//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation
import XCTest

class LoadFeedImageDataLoader {
    
    let store:Any
    init(store:Any){
        self.store = store
    }
}
class LocalFeedImageDataLoaderTests:XCTestCase{
    
    
    func test_init_doesNotMessageStoreUponCreation(){
        let store = FeedStoreSpy()
        let sut = LoadFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LoadFeedImageDataLoader, store: FeedStoreSpy) {
            let store = FeedStoreSpy()
            let sut = LoadFeedImageDataLoader(store: store)
            trackForMemoryLeaks(store, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, store)
        }
    
    
    private class FeedStoreSpy {
        let messages = [Any]()
        
        init() {
            
        }
    }
    
}
