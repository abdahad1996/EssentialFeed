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
        let (sut,client) = makeSut(url: url)
        
        
        sut.load()
        
        XCTAssertEqual(client.requestedUrls,[url])
        
    }
    
    func test_loadTwice_shouldRequestDataFromUrlTwice(){
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSut(url: url)
        
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedUrls,[url,url])
        
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSut()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load{capturedErrors.append($0)}
        
        let clientError = NSError(domain: "", code: 1)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors,[.connectivity])
    }
    
    
    
    
    
    // MARK: - Helpers
    
    private func makeSut(url:URL = URL(string: "https//google.com")!) -> (RemoteFeedLoader,HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)
        
        return (sut,client)
        
    }
    
    class HttpClientSpy:HttpClient{
        
        var messages = [(url: URL, completion:(Error) -> Void)]()
        
        var requestedUrls:[URL]{
            return messages.map{$0.url}
        }
        func complete(with error:Error,at index:Int = 0){
            messages[index].completion(error)
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url,completion))
            
        }
    }
}
