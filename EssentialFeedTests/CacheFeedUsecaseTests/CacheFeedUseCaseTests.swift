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
    typealias insertCompletion = (Error?) -> Void

    var deleteCacheFeedCallCount = 0
    
    var deletionCompletion = [deleteCompletion]()
    var insertionCompletion = [insertCompletion]()

    
    enum ReceivedMessages:Equatable{
        case deleteCacheFeed
        case insert(items:[FeedItem],timeStamp:Date)
    }
    
    var receivedMessages = [ReceivedMessages]()

    func deleteCacheFeed(completion:@escaping (Error?) -> Void){
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error:Error,at index:Int = 0){
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessFully(at index:Int = 0){
        deletionCompletion[index](nil)
    }
    
    func completeInsertion(with error:Error, at index:Int = 0){
        insertionCompletion[index](error)
    }
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletion[index](nil)
    }
    
    func insert(_ items:[FeedItem],timeStamp:Date,completion:@escaping (Error?) -> Void){
        receivedMessages.append(.insert(items: items, timeStamp: timeStamp))
        insertionCompletion.append(completion)
    }
}

class LocalFeedStore{
    let store:FeedStore
    let currentTimeStamp:() -> Date
    
    init(store: FeedStore,currentTimeStamp:@escaping () -> Date) {
        self.store = store
        self.currentTimeStamp = currentTimeStamp
    }
    
    func save(items:[FeedItem],completion:@escaping (Error?) -> Void ){
        store.deleteCacheFeed {[unowned self] error in
            
            if error == nil{
                self.store.insert(items,timeStamp: self.currentTimeStamp(), completion: completion)
            }else{
                completion(error)
            }
        }
    }
    
     
    
}
class CacheFeedUseCaseTests:XCTestCase{
    func test_init_doesNotMessageStoreUponCreation(){
        let (store,_) = makeSut()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    
    func test_save_requestsCacheDeletion(){
        
        let (store,sut) = makeSut()
        let items = [uniqueItem()]
        sut.save(items:items, completion: {_ in})
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (store,sut) = makeSut()
        let items = [uniqueItem()]
        let deletionError = anyError()
        
        sut.save(items:items, completion: {_ in})

        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
        
    }
    
    
    func test_save_requestsNewCacheWithTimeStampInsertionOnSuccessfulDeletion(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let items = [uniqueItem()]
       
        sut.save(items:items, completion: {_ in})
        store.completeDeletionSuccessFully()
       

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed,.insert(items: items, timeStamp: date)])



    }
    
    func test_save_failsOnDeletionError(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let items = [uniqueItem()]
        let deletionError = anyError()

        var receievedError:NSError?
        sut.save(items: items) { error in
            receievedError = error as? NSError
        }
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(deletionError, receievedError)
        
    }
    
    func test_save_failsOnInsertionErrorOnSuccessfulDeletion(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let items = [uniqueItem()]
        let insertionError = anyError()

        var receievedError:NSError?
        
        sut.save(items: items) { error in
            receievedError = error as? NSError
        }
        
        store.completeDeletionSuccessFully()
        
        store.completeInsertion(with: insertionError)
        
        XCTAssertEqual(insertionError, receievedError)
        
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let items = [uniqueItem()]
        
        var receievedError:NSError?
        
        sut.save(items: items) { error in
            receievedError = error as? NSError
        }
        
        store.completeDeletionSuccessFully()
        
        store.completeInsertionSuccessfully()
        
        XCTAssertNil(receievedError)
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
