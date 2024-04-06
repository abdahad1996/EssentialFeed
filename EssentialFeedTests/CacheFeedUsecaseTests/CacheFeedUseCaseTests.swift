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
}
class CacheFeedUseCaseTests:XCTestCase{
    func test_init_doesNotDeleteCacheUponCreation(){
        let (store,_) = makeSut()
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    
    func test_save_requestsCacheDeletion(){
        let (store,sut) = makeSut()
        
        sut.save(items: [uniqueItem()])
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    func makeSut() -> (FeedStore,LocalFeedStore){
        let store = FeedStore()
        let localFeedStore = LocalFeedStore(feedStore: store)
        return (store,localFeedStore)
    }
    
    private func uniqueItem() -> FeedItem{
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyUrl())
    }
    
    func anyUrl() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
