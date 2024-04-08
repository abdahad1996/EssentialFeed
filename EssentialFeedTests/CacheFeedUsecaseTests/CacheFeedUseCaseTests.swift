//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 06/04/2024.
//

import Foundation
import XCTest
import EssentialFeed





class CacheFeedUseCaseTests:XCTestCase{
    func test_init_doesNotMessageStoreUponCreation(){
        let (store,_) = makeSut()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    
    func test_save_requestsCacheDeletion(){
        
        let (store,sut) = makeSut()
        let items = uniqueImages()
        sut.save(items:items.models, completion: {_ in})
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (store,sut) = makeSut()
        let items = uniqueImages()
        let deletionError = anyError()
        
        sut.save(items:items.models, completion: {_ in})
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
        
    }
    
    
    func test_save_requestsNewCacheWithTimeStampInsertionOnSuccessfulDeletion(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let items = uniqueImages()
        
        
        sut.save(items:items.models, completion: {_ in})
        store.completeDeletionSuccessFully()
        
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed,.insert(items: items.local, timeStamp: date)])
        
    }
    
    func test_save_failsOnDeletionError(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let deletionError = anyError()
        
        
        expect(sut: sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
        
        
        
        
    }
    
    func test_save_failsOnInsertionErrorOnSuccessfulDeletion(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        let insertionError = anyError()
        
        expect(sut: sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessFully()
            store.completeInsertion(with: insertionError)
        })
        
        
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion(){
        let date = Date()
        let (store,sut) = makeSut(currentTimeStamp: {date})
        
        expect(sut: sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessFully()
            store.completeInsertionSuccessfully()
        })
        
        
    }
    
    func test_save_DoesNotDeliverDeletionErrorAfterSutHasBeenDisallocated(){
        var sut:LocalFeedStore?
        let store = FeedStoreSpy()
        sut = LocalFeedStore(store:store, currentTimeStamp:  Date.init)
        let items = uniqueImages()
        
        var receivedError = [LocalFeedStore.saveResult]()
        sut?.save(items: items.models, completion: { error in
            receivedError.append(error)
        })
        
        sut = nil
        store.completeDeletion(with:anyError())
        
        XCTAssertTrue(receivedError.isEmpty)
        
        
        
        
    }
    
    func test_save_DoesNotDeliverInsertionErrorAfterSutHasBeenDisallocated(){
        var sut:LocalFeedStore?
        let store = FeedStoreSpy()
        sut = LocalFeedStore(store:store, currentTimeStamp:  Date.init)
        
        let items = uniqueImages()
        var receivedError = [LocalFeedStore.saveResult]()
        
        sut?.save(items:items.models , completion: { error in
            receivedError.append(error)
            
        })
        
        
        store.completeDeletionSuccessFully()
        sut = nil
        store.completeInsertion(with: anyError())
        
        
        XCTAssertTrue(receivedError.isEmpty)
        
        
        
        
    }
    
    func expect(sut:LocalFeedStore,toCompleteWithError expectedError:NSError?,when action:()->Void,file:StaticString = #file,line:UInt = #line){
        var receievedResults = [LocalFeedStore.saveResult]()
        let expectation = expectation(description: "wait for save completion")
        
        sut.save(items: [uniqueImage()]) { error in
            receievedResults.append(error)
            expectation.fulfill()
        }
        
        action()
        XCTAssertEqual(receievedResults.map{$0 as NSError?},[expectedError])
        wait(for: [expectation],timeout: 0.1)
    }
    
    func makeSut(
        currentTimeStamp:@escaping () -> Date = Date.init,
        file:StaticString = #file,
        line:UInt = #line
    ) -> (
        FeedStoreSpy,
        LocalFeedStore
    ){
        let store = FeedStoreSpy()
        let localFeedStore = LocalFeedStore(store: store, currentTimeStamp: currentTimeStamp)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(localFeedStore,file: file,line: line)
        return (store,localFeedStore)
    }
    
    private func uniqueImage() -> FeedImage{
        return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyUrl())
    }
    
    private func uniqueImages() -> (
        models:[FeedImage],
        local:[LocalFeedImage]
    ){
        let models = [uniqueImage(),uniqueImage()]
        let local = models.map{LocalFeedImage(id: $0.id,description: $0.description,location: $0.location, imageURL: $0.url)}
        
        return (models,local)
    }
    
    func anyUrl() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    // Mark:Helper
    class FeedStoreSpy:FeedStore{
        typealias deleteCompletion = (Error?) -> Void
        typealias insertCompletion = (Error?) -> Void
        
        var deleteCacheFeedCallCount = 0
        
        var deletionCompletion = [deleteCompletion]()
        var insertionCompletion = [insertCompletion]()
        
        
        enum ReceivedMessages:Equatable{
            case deleteCacheFeed
            case insert(items:[LocalFeedImage],timeStamp:Date)
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
        
        func insert(_ items:[LocalFeedImage],timeStamp:Date,completion:@escaping (Error?) -> Void){
            receivedMessages.append(.insert(items: items, timeStamp: timeStamp))
            insertionCompletion.append(completion)
        }
    }
}
