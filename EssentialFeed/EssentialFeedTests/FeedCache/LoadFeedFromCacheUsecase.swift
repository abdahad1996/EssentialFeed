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
    
    func test_load_requestsCacheRetrieval(){
        let (store,sut) = makeSut()
        
       _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError(){
        let (store,sut) = makeSut()
        let retrievalError = anyNSError()

        expect(sut: sut, completeWith:.failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        
        let (store,sut) = makeSut()
        expect(sut: sut, completeWith:.success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let nonExpiredCacheTimeStamp = fixedDate.minusFeedCacheMaxAge().adding(seconds:1)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        
        expect(sut: sut, completeWith: .success(feedImages.models)) {
            store.completeRetrieval(with: feedImages.local, timestamp: nonExpiredCacheTimeStamp)
            
        }
    }
    
    func test_load_deliversNoImageOnCacheExpiration() {
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let expiringCacheTimeStamp = fixedDate.minusFeedCacheMaxAge()
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        
        expect(sut: sut, completeWith: .success([])) {
            store.completeRetrieval(with: feedImages.local, timestamp: expiringCacheTimeStamp)
            
        }
    }
    func test_load_deliversNoImagesOnExpiredCache() {
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let expiredCacheTimeStamp = fixedDate.minusFeedCacheMaxAge().adding(seconds:-1)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        
        expect(sut: sut, completeWith: .success([])) {
            store.completeRetrieval(with: feedImages.local, timestamp: expiredCacheTimeStamp)
            
        }
    }
    
    func test_load_hasNoSideEffectOnRetrievalError() {
        let (store,sut) = makeSut()
        store.completeRetrieval(with: anyNSError())

       _ = try? sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
    }

    func test_load_hasNoSideEffectOnEmptyCache() {
        let (store,sut) = makeSut()
        store.completeRetrieval(with: anyNSError())

       _ = try? sut.load()
        
//        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() {
        
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let nonExpiredCacheTimeStamp = fixedDate.minusFeedCacheMaxAge().adding(seconds:1)
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        store.completeRetrieval(with: feedImages.local, timestamp: nonExpiredCacheTimeStamp)
        
       _ = try? sut.load()

        
//        store.completeRetrieval(with: feedImages.local, timestamp: nonExpiredCacheTimeStamp)
            
        XCTAssertEqual(store.receivedMessages, [.retrieve])

        
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration() {
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let expiringCacheTimeStamp = fixedDate.minusFeedCacheMaxAge()
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        store.completeRetrieval(with: feedImages.local, timestamp: expiringCacheTimeStamp)

       _ = try? sut.load()
            
        XCTAssertEqual(store.receivedMessages, [.retrieve])

    }

    func test_load_hasNoSideEffectOnExpiredCache() {
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let expiredCacheTimeStamp = fixedDate.minusFeedCacheMaxAge().adding(seconds:-1)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        store.completeRetrieval(with: feedImages.local, timestamp: expiredCacheTimeStamp)

        
       _ = try? sut.load()
 
        XCTAssertEqual(store.receivedMessages, [.retrieve,])

        
    }
    
//    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
//        var store = FeedStoreSpy()
//        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
//        
//        var receivedResult = [LocalFeedLoader.LoadResult]()
//        
//        sut?.load(completion: { result in
//            receivedResult.append(result)
//        })
//        sut = nil
//        
//        store.completeRetrievalWithEmptyCache()
//        
//        XCTAssertTrue(receivedResult.isEmpty)
//        
//        
//    }
    func makeSut(
        currentTimeStamp:@escaping () -> Date = Date.init,
        file:StaticString = #file,
        line:UInt = #line
    ) -> (
        FeedStoreSpy,
        LocalFeedLoader
    ){
        let store = FeedStoreSpy()
        let localFeedStore = LocalFeedLoader(store: store, currentDate: currentTimeStamp)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(localFeedStore,file: file,line: line)
        return (store,localFeedStore)
    }
    
    func expect(sut:LocalFeedLoader,completeWith expectedResult:Swift.Result<[FeedImage], Error>,when action:()->Void,file:StaticString = #file,line:UInt = #line){
               
        action()
        let receivedResult = Result { try sut.load() }
       
            switch (receivedResult,expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages,file:file,line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)) :
            XCTAssertEqual(receivedError, expectedError,file:file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                
            }  
        
        
    }
    
    
    
}

