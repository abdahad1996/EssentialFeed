////
////  RemoteFeedImageDataLoaderTests.swift
////  EssentialFeedTests
////
////  Created by macbook abdul on 11/06/2024.
////
//
//import Foundation
//import XCTest
//import EssentialFeed
//
//
//class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
//    
//    
//    func test_init_doesNotPerformanyURLRequest() {
//        let (_,client) = makeSUT()
//        
//        XCTAssertTrue(client.requestedUrls.isEmpty)
//    }
//    
//    func test_loadImageDataFromURL_requestsDataFromURL(){
//        let (sut,client) = makeSUT()
//        let url = anyURL()
//        
//        sut.loadImageData(from: url, completion: {_ in})
//        
//        XCTAssertEqual(client.requestedUrls,[url])
//        
//    }
//    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
//        let (sut,client) = makeSUT()
//        let url = anyURL()
//        
//        sut.loadImageData(from: url, completion: {_ in})
//        sut.loadImageData(from: url, completion: {_ in})
//        
//        XCTAssertEqual(client.requestedUrls,[url,url])
//        
//    }
//    
//    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
//        
//        let (sut,client) = makeSUT()
//        let clientError = NSError(domain: "a client error", code: 0)
//        expect(sut, toCompleteWith: failure(.connectivity)) {
//            client.complete(with: clientError)
//            
//        }
//    }
//    
//    
//    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
//        
//        let (sut,client) = makeSUT()
//        let samples = [199, 201, 300, 400, 500]
//        
//        samples.enumerated().forEach { index,code in
//            expect(sut, toCompleteWith:failure(.invalidData) ) {
//                client.complete(with: anyData(), statusCode: code,at:index)
//                
//            }
//        }
//        
//        
//    }
//    
//    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
//        let (sut, client) = makeSUT()
//        
//        expect(sut, toCompleteWith: failure(.invalidData)) {
//            let emptyData = Data()
//            client.complete(with: emptyData, statusCode: 200)
//            
//        }
//    }
//    
//    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
//        
//        let (sut, client) = makeSUT()
//        let nonEmptyData = Data("non empty data".utf8)
//        
//        
//        expect(sut, toCompleteWith: .success(nonEmptyData)) {
//            client.complete(with: nonEmptyData, statusCode: 200)
//            
//        }
//        
//        
//        
//    }
//    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
//        let client = HTTPClientSpy()
//        var sut:RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
//        
//        var capturedResults = [FeedImageDataLoader.Result]()
//        sut?.loadImageData(from: anyURL(), completion: { result in
//            capturedResults.append(result)
//        })
//        
//        sut = nil
//        
//        client.complete(with: anyData(), statusCode: 200)
//        
//        XCTAssertTrue(capturedResults.isEmpty)
//        
//        
//    }
//    
//    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
//        let (sut, client) = makeSUT()
//        let url = anyURL()
//        let task = sut.loadImageData(from: anyURL()){_ in}
//        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
//        
//        task.cancel()
//        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
//        
//        
//    }
//    
//    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
//        
//        let (sut, client) = makeSUT()
//        let url = anyURL()
//        let nonEmptyData = Data("non-empty data".utf8)
//        var receivedResult = [FeedImageDataLoader.Result]()
//        
//        let task = sut.loadImageData(from: anyURL()){ result in
//            receivedResult.append(result)
//        }
//        
//        task.cancel()
//        
//        client.complete(with: anyData(), statusCode: 404)
//        client.complete(with: nonEmptyData, statusCode: 200)
//        client.complete(with: anyNSError())
//        
//        XCTAssertTrue(receivedResult.isEmpty)
//        
//    }
//    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
//        return .failure(error)
//    }
//    
//   
//    
//    private func expect(_ sut: RemoteFeedImageDataLoader,toCompleteWith expectedResult: FeedImageDataLoader.Result,action:() -> Void,file: StaticString = #file, line: UInt = #line){
//        let url = URL(string: "https://a-given-url.com")!
//        let exp = expectation(description: "Wait for load completion")
//        sut.loadImageData(from: url) { receivedResult in
//            switch(receivedResult,expectedResult){
//                
//            case let (.success(receivedData),.success(expectedData)):
//                XCTAssertEqual(receivedData ,expectedData,file: file,line: line)
//                
//            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error),.failure(expectedError as RemoteFeedImageDataLoader.Error)):
//                
//                XCTAssertEqual(receivedError ,expectedError ,file: file,line: line)
//                
//                
//            default:
//                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
//                
//                
//            }
//            exp.fulfill()
//        }
//        
//        action()
//        wait(for: [exp], timeout: 1.0)
//        
//    }
//    
//    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
//        let client = HTTPClientSpy()
//        let sut = RemoteFeedImageDataLoader(client: client)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        trackForMemoryLeaks(client, file: file, line: line)
//        return (sut, client)
//    }
//    
//    
//    
//}
