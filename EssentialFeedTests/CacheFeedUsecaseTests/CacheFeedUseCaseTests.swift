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
    typealias deleteCompletion = (Error?) -> Void
   var deleteCacheFeedCallCount = 0
  var insertCacheFeedCallCount = 0
    
    var deletionCompletion = [deleteCompletion]()
    
    func deleteCacheFeed(completion:@escaping (Error?) -> Void){
        deleteCacheFeedCallCount += 1
        deletionCompletion.append(completion)
    }
    
    func completeDeletion(with error:Error,at index:Int = 0){
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessFully(at index:Int = 0){
        deletionCompletion[index](nil)

    }
    
    func insert(_ items:[FeedItem]){
        insertCacheFeedCallCount += 1
    }
}

class LocalFeedStore{
    let store:FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items:[FeedItem]){
        store.deleteCacheFeed {[unowned self] error in
            if error == nil{
                self.store.insert(items)
            }
        }
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
        
        sut.save(items: items)
        
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertCacheFeedCallCount, 0)
        
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion(){
        let (store,sut) = makeSut()
        let items = [uniqueItem()]
       
        sut.save(items:items)
        store.completeDeletionSuccessFully()
        
        
        
        sut.save(items: [uniqueItem()])
        XCTAssertEqual(store.insertCacheFeedCallCount, 1)

    }
    
    func makeSut(file:StaticString = #file, line:UInt = #line) -> (FeedStore,LocalFeedStore){
        let store = FeedStore()
        let localFeedStore = LocalFeedStore(store: store)
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
