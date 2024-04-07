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
    typealias insertionCompletion = (Error?) -> Void

    var deleteCacheFeedCallCount = 0
    
    var deletionCompletion = [deleteCompletion]()
    var insertions = [(items:[FeedItem],timeStamp:Date)]()

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
    
    func insert(_ items:[FeedItem],timeStamp:Date){
        insertCacheFeedCallCount += 1
        insertions.append((items: items, timeStamp: timeStamp))
    }
}

class LocalFeedStore{
    let store:FeedStore
    let currentTimeStamp:() -> Date
    
    init(store: FeedStore,currentTimeStamp:@escaping () -> Date) {
        self.store = store
        self.currentTimeStamp = currentTimeStamp
    }
    
    func save(items:[FeedItem]){
        store.deleteCacheFeed {[unowned self] error in
            if error == nil{
                self.store.insert(items,timeStamp: self.currentTimeStamp())
            }
        }
    }
    
     
    
}
class CacheFeedUseCaseTests:XCTestCase{
    func test_init_doesNotDeleteCacheUponCreation(){
        let (store,_) = makeSut()
        XCTAssertEqual(store.deletionCompletion.count, 0)
    }
    
    
    func test_save_requestsCacheDeletion(){
        
        let (store,sut) = makeSut()
        let items = [uniqueItem()]
        sut.save(items:items)
        
        XCTAssertEqual(store.deletionCompletion.count, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (store,sut) = makeSut()
        let items = [uniqueItem()]
        let deletionError = anyError()
        
        sut.save(items: items)
        
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertions.count, 0)
        
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion(){
        let (store,sut) = makeSut()
        let items = [uniqueItem(),uniqueItem()]
       
        sut.save(items:items)
        store.completeDeletionSuccessFully()
        
        XCTAssertEqual(store.insertions.count, 1)

    }
    
    func test_save_requestsNewCacheWithTimeStampInsertionOnSuccessfulDeletion(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let items = [uniqueItem()]
       
        sut.save(items: items)
        store.completeDeletionSuccessFully()
       
        XCTAssertEqual(store.insertions.first?.items,items)
        XCTAssertEqual(store.insertions.first?.timeStamp,date)



    }
    
    func makeSut(currentTimeStamp:@escaping () -> Date = Date.init,file:StaticString = #file, line:UInt = #line) -> (FeedStore,LocalFeedStore){
        let store = FeedStore()
        let localFeedStore = LocalFeedStore(store: store, currentTimeStamp: currentTimeStamp)
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
