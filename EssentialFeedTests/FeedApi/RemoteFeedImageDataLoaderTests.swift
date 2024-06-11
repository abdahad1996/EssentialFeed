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
    
    func loadImageData(from url: URL,completion:@escaping(FeedImageLoader.Result) -> Void) {
        client.get(from: url, completion: {_ in})
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
    
    private func makeSUT(url: URL = anyUrl(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy:HTTPClient {
        
        var urls = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            urls.append(url)
        }
        
    }
    
    
    
    
    
    
}
