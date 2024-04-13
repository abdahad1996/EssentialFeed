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
        let lessThanSevenDaysOldTimeStamp = fixedDate.adding(days:-7).adding(seconds:1)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        
        expect(sut: sut, completeWith: .success(feedImages.models)) {
            store.completeRetrieval(with: feedImages.local, timeStamp: lessThanSevenDaysOldTimeStamp)
            
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let lessThanSevenDaysOldTimeStamp = fixedDate.adding(days:-7)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        
        expect(sut: sut, completeWith: .success([])) {
            store.completeRetrieval(with: feedImages.local, timeStamp: lessThanSevenDaysOldTimeStamp)
            
        }
    }
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let fixedDate = Date()
        let feedImages = uniqueImages()
        let lessThanSevenDaysOldTimeStamp = fixedDate.adding(days:-7).adding(seconds:-1)
        
        let (store,sut) = makeSut(currentTimeStamp: {fixedDate})
        
        expect(sut: sut, completeWith: .success([])) {
            store.completeRetrieval(with: feedImages.local, timeStamp: lessThanSevenDaysOldTimeStamp)
            
        }
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (store,sut) = makeSut()
        
        sut.load{_ in}
        
        store.completeRetrieval(with: anyError())
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
    
    func expect(sut:LocalFeedStore,completeWith expectedResult:LoadFeedResult,when action:()->Void,file:StaticString = #file,line:UInt = #line){
               
        let exp = expectation(description: "wait for completion")
        sut.load { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages,file:file,line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)) :
            XCTAssertEqual(receivedError, expectedError,file:file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                
            }  
            exp.fulfill()
       }
        
        action()
        wait(for: [exp],timeout: 0.1)
        
        
    }
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
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
    
}

private extension Date{
    func adding(days:Int) -> Self {
        return Calendar(identifier: .gregorian).date(byAdding: .day,value: days,to: self)!
    }
    func adding(seconds:TimeInterval) -> Self {
        return self + seconds
    }
}
