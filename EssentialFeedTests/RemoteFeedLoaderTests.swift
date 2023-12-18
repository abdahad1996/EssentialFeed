//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdul Ahad on 18.12.23.
//

import XCTest

class RemoteFeedLoader{
   
    
    func load(){
        HttpClient.shared.requestedURL = URL(string: "http//google.com")
    }
}
class HttpClient{
    var requestedURL:URL?
    static let shared = HttpClient()
    private init(){}
    
   
}
class RemoteFeedLoaderTests:XCTestCase{
    func test_init_doesNotRequestDataFromUrl(){
        let client = HttpClient.shared
        let sut = RemoteFeedLoader()
       
        
        
        XCTAssertNil(client.requestedURL)
        
    }
//    
    func test_load_shouldRequestDataFromUrl(){
        let client = HttpClient.shared
        let sut = RemoteFeedLoader()
       
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        
        
    }
}
