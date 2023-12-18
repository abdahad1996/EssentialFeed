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
    
//    func load(){
//        client.get(url: <#T##URL#>)
//    }
}
class HttpClient{
    var requestedURL:URL?
    func get(url:URL){
        self.requestedURL = url
    }
}
class RemoteFeedLoaderTests:XCTestCase{
    func test_init_doesNotRequestDataFromUrl(){
        let client = HttpClient()
        let sut = RemoteFeedLoader(client: client)
       
        
        
        XCTAssertNil(client.requestedURL)
        
    }
//    
//    func test_load_shouldRequestDataFromUrl(){
//        let client = HttpClient()
//        let sut = RemoteFeedLoader(client: client)
//       
//        
//        sut.load()
//        
//        XCTAssertNotNil(client.requestedURL)
//        
//        
//    }
}
