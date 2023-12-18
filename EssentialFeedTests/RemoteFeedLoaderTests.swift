//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdul Ahad on 18.12.23.
//

import XCTest

class RemoteFeedLoader{
    let client:HttpClient
    init(client: HttpClient) {
        self.client = client
    }
    
    
    func load(){
        client.get(from: URL(string: "http//google.com")!)
    }
}
protocol HttpClient{
    
    func get(from url:URL)
   
}

class HttpClientSpy:HttpClient{
    var requestedURL:URL?
     func get(from url:URL){
        requestedURL = url
    }
}
class RemoteFeedLoaderTests:XCTestCase{
    func test_init_doesNotRequestDataFromUrl(){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(client: client)
       
        
        
        XCTAssertNil(client.requestedURL)
        
    }
//    
    func test_load_shouldRequestDataFromUrl(){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(client:client)
       
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        
        
    }
}
