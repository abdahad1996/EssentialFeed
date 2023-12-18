//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdul Ahad on 18.12.23.
//

import XCTest

class RemoteFeedLoader{
   
    
    func load(){
        HttpClient.shared.get(from: URL(string: "http//google.com")!)
    }
}
class HttpClient{
    static var shared = HttpClient()
//    private init(){}
    func get(from url:URL){
       
    }
   
}

class HttpClientSpy:HttpClient{
    var requestedURL:URL?
    override func get(from url:URL){
        requestedURL = url
    }
}
class RemoteFeedLoaderTests:XCTestCase{
    func test_init_doesNotRequestDataFromUrl(){
        let client = HttpClientSpy()
        HttpClientSpy.shared = client
        let sut = RemoteFeedLoader()
       
        
        
        XCTAssertNil(client.requestedURL)
        
    }
//    
    func test_load_shouldRequestDataFromUrl(){
        let client = HttpClientSpy()
        HttpClientSpy.shared = client
        let sut = RemoteFeedLoader()
       
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        
        
    }
}
