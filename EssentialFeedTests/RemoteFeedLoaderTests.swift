//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdul Ahad on 18.12.23.
//

import XCTest

class RemoteFeedLoader{
    
    let url:URL
    let client:HttpClient
    
    init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    
    func load(){
        client.get(from: url)
    }
}
protocol HttpClient{
    func get(from url:URL)
    
}


class RemoteFeedLoaderTests:XCTestCase{
    func test_init_doesNotRequestDataFromUrl(){
        let (_,client) = makeSut()
        
        
        XCTAssertNil(client.requestedURL)
        
    }
    //
    func test_load_shouldRequestDataFromUrl(){
        let url = URL(string: "https://a-given-url.com")!
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)

        
        sut.load()
        
        XCTAssertEqual(client.requestedURL,url)
        
    }
    
    class HttpClientSpy:HttpClient{
        var requestedURL:URL?
        func get(from url:URL){
            requestedURL = url
        }
    }
    
    private func makeSut(url:URL = URL(string: "https//google.com")!) -> (RemoteFeedLoader,HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)
        
        return (sut,client)

    }
}
