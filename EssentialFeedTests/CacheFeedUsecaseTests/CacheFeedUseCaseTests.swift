//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 06/04/2024.
//

import Foundation
import XCTest

class FeedStore{
   var deleteCacheFeedCallCount = 0
}

class LocalFeedStore{
    let feedStore:FeedStore
    init(feedStore: FeedStore) {
        self.feedStore = feedStore
    }
}
class CacheFeedUseCaseTests:XCTestCase{
    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        let sut = LocalFeedStore(feedStore: store)
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
}
