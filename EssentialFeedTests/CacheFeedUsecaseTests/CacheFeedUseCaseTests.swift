//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 06/04/2024.
//

import Foundation
import XCTest
import EssentialFeed

class FeedStore{
   var deleteCacheFeedCallCount = 0
    var insertCacheFeedCallCount = 0
    
    func deleteCacheFeed(){
        deleteCacheFeedCallCount += 1
    }
}

class LocalFeedStore{
    let feedStore:FeedStore
    init(feedStore: FeedStore) {
        self.feedStore = feedStore
    }
    func save(items:[FeedItem]){
        feedStore.deleteCacheFeed()
    }
    
    func completeDeletion(with error:Error,at index:Int = 0){
        
    }
}
class CacheFeedUseCaseTests:XCTestCase{
    func test_init_doesNotDeleteCacheUponCreation(){
        let (store,_) = makeSut()
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    
    func test_save_requestsCacheDeletion(){
        
        let (store,sut) = makeSut()
        let items = [uniqueItem()]
        sut.save(items:items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (store,sut) = makeSut()
        let items = [uniqueItem()]
        let deletionError = anyError()
        
        sut.save(items: [uniqueItem()])
        
        sut.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertCacheFeedCallCount, 0)

        
    }
    
    func makeSut(file:StaticString = #file, line:UInt = #line) -> (FeedStore,LocalFeedStore){
        let store = FeedStore()
        let localFeedStore = LocalFeedStore(feedStore: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(localFeedStore,file: file,line: line)
        return (store,localFeedStore)
    }
    
    private func uniqueItem() -> FeedItem{
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyUrl())
    }
    
    func anyUrl() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
