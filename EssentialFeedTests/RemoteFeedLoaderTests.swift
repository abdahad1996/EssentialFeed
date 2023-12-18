//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdul Ahad on 18.12.23.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests:XCTestCase{
    func test_init_doesNotRequestDataFromUrl(){
        let (_,client) = makeSut()
        
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
        
    }
    
    func test_load_shouldRequestDataFromUrl(){
        let url = URL(string: "https://a-given-url.com")!
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)

        
        sut.load()
        
        XCTAssertEqual(client.requestedUrls,[url])
        
    }
    
    func test_loadTwice_shouldRequestDataFromUrlTwice(){
        let url = URL(string: "https://a-given-url.com")!
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)

        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedUrls,[url,url])
        
    }
    
    // MARK: - Helpers
    
    private func makeSut(url:URL = URL(string: "https//google.com")!) -> (RemoteFeedLoader,HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)
        
        return (sut,client)

    }
    
    class HttpClientSpy:HttpClient{
        var requestedUrls : [URL] = []
        
        func get(from url:URL){
            requestedUrls.append(url)
        }
    }
}
