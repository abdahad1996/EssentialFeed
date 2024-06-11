//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 11/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    let client:HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL,completion:@escaping(FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result{
            case let .failure(error):
                completion(.failure(error))
            default:break
            }
            
        }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.urls.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL(){
        let (sut,client) = makeSUT()
        let url = anyUrl()
        
        sut.loadImageData(from: url, completion: {_ in})
        
        XCTAssertEqual(client.urls,[url])
        
    }
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut,client) = makeSUT()
        let url = anyUrl()
        
        sut.loadImageData(from: url, completion: {_ in})
        sut.loadImageData(from: url, completion: {_ in})
        
        XCTAssertEqual(client.urls,[url,url])
        
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        
        let (sut,client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)
        
        expect(sut, toCompleteWith: .failure(clientError)) {
            client.complete(with: clientError)
            
        }
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader,toCompleteWith expectedResult: FeedImageDataLoader.Result,action:() -> Void,file: StaticString = #file, line: UInt = #line){
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        sut.loadImageData(from: url) { receivedResult in
            switch(receivedResult,expectedResult){
            case let (.failure(receivedError),.failure(expectedError)):
                
                XCTAssertEqual(receivedError as NSError,expectedError as NSError,file: file,line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            
            
        }
        exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
    
}

private func makeSUT(url: URL = anyUrl(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedImageDataLoader(client: client)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
}

private class HTTPClientSpy:HTTPClient {
    
    var completions = [(url:URL,completion:(HTTPClient.Result) -> Void)]()
    
    var urls:[URL] {
        completions.map {$0.url}
    }
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        completions.append((url:url,completion:completion))
    }
    
    func complete(with error:Error,at index:Int = 0) {
        completions[index].completion(.failure(error))
    }
    
}






}
