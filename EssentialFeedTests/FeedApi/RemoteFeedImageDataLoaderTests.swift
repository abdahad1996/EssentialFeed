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
    public enum Error: Swift.Error {
            case invalidData
            case connectivity
        }
    
    func loadImageData(from url: URL,completion:@escaping(FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result{
            case let .success(_,_):
                completion(.failure(Error.invalidData))
                
            case let .failure(_):
                completion(.failure(Error.connectivity))
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
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: RemoteFeedImageDataLoader.Error.connectivity)
            
        }
    }
    
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        
        let (sut,client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith:failure(.invalidData) ) {
                client.complete(with: anyData(), statusCode: code,at:index)
                
            }
        }
        
       
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
            return .failure(error)
        }
    
    private func anyData() -> Data{
        Data("any data".utf8)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader,toCompleteWith expectedResult: FeedImageDataLoader.Result,action:() -> Void,file: StaticString = #file, line: UInt = #line){
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        sut.loadImageData(from: url) { receivedResult in
            switch(receivedResult,expectedResult){
                
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData ,expectedData,file: file,line: line)
                
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error),.failure(expectedError as RemoteFeedImageDataLoader.Error)):
                
                XCTAssertEqual(receivedError ,expectedError ,file: file,line: line)
                
            
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
    
    func complete(with data:Data,statusCode:Int,at index:Int = 0) {
        let response = HTTPURLResponse(url: urls[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        completions[index].completion(.success((data, response)))
    }
    
}






}
