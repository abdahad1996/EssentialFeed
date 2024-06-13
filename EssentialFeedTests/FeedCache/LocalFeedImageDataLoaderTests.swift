//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL)
}
class LoadFeedImageDataLoader {
    
    let store:FeedImageDataStore
    init(store:FeedImageDataStore){
        self.store = store
    }
    
    struct Task:FeedImageDataLoaderTask{
        func cancel() {
            
        }
    }
    func loadImageData(from url: URL,completion:@escaping(FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
}
class LocalFeedImageDataLoaderTests:XCTestCase{
    
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL(){
        let (sut,store) = makeSUT()
        let url = anyUrl()
        
        sut.loadImageData(from: url) {_ in}
        
        XCTAssertEqual(store.messages,[.retreival(url: url)])


    }
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LoadFeedImageDataLoader, store: StoreSpy) {
            let store = StoreSpy()
            let sut = LoadFeedImageDataLoader(store: store)
            trackForMemoryLeaks(store, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, store)
        }
    
    
    private class StoreSpy:FeedImageDataStore {
        
        var messages = [Message]()
        
        enum Message:Equatable {
            case retreival(url:URL)
        }
        
        init() {}
        func retrieve(dataForURL url: URL) {
            messages.append(.retreival(url: url))
        }
        
       
    }
    
}
