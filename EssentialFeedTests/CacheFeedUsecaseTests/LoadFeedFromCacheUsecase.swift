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
        
        sut.load{_ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError(){
        let (store,sut) = makeSut()
        let retrievalError = anyError()
        
        let exp = expectation(description: "wait for completion")
        
        var receivedErrors = [Error?]()
        sut.load { result in
            switch result {
            case let .failure(receivedError):
                receivedErrors.append(receivedError)
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrieval(with: .failure(retrievalError))
        
        XCTAssertEqual(receivedErrors.map{$0 as NSError?}, [retrievalError])
        wait(for: [exp],timeout: 0.1)
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        
        let (store,sut) = makeSut()
        
        var receivedImages = [FeedImage]()
        let exp = expectation(description: "wait for completion")
        
         sut.load { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrieval(with: .success([]))
        
        XCTAssertEqual(receivedImages, [])
        wait(for: [exp],timeout: 0.1)
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
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    
}
