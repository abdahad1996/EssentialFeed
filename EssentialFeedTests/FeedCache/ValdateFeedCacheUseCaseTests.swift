//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 06/04/2024.
//

import Foundation
import XCTest
import EssentialFeed


class ValidateFeedCacheUseCaseTests:XCTestCase{
    func test_init_doesNotMessageStoreUponCreation(){
        let (store,_) = makeSut()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_ValidateCache_deleteCacheOnRetrievalError(){
        let (store,sut) = makeSut()
        
        sut.validateCache()
        store.completeRetrieval(with: anyError())
        
        
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])

    }
    
    func test_ValidateCache_doesNotDeleteCacheOnEmptyCache(){
        let (store,sut) = makeSut()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])

    }
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache(){
        
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let lessThanSevenDaysOldTimeStamp = fixedDate.adding(days:-7).adding(seconds:1)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        sut.validateCache()

        
        store.completeRetrieval(with: feedImages.local, timeStamp: lessThanSevenDaysOldTimeStamp)
            
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_DeletesCacheOnSevenDaysOldCache(){
        
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let lessThanSevenDaysOldTimeStamp = fixedDate.adding(days:-7)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        sut.validateCache()

        
        store.completeRetrieval(with: feedImages.local, timeStamp: lessThanSevenDaysOldTimeStamp)
            
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
    }
    
    func test_validateCache_DeletesCacheOnMoreThanSevenDaysOldCache(){
        
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let lessThanSevenDaysOldTimeStamp = fixedDate.adding(days:-7).adding(seconds: -1)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        sut.validateCache()

        store.completeRetrieval(with: feedImages.local, timeStamp: lessThanSevenDaysOldTimeStamp)
            
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
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
    
    

}
