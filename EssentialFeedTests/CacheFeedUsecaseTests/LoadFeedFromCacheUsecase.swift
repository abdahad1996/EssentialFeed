//
//  LoadFeedFromCacheUsecase.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 08/04/2024.
//


import Foundation
import XCTest
import EssentialFeed


class LoadFeedFromCacheUseCaseTests:XCTestCase{
    func test_init_doesNotMessageStoreUponCreation(){
        let (store,_) = makeSut()
        XCTAssertEqual(store.receivedMessages, [])
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
