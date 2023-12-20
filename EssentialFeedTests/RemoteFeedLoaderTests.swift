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
        
        
        sut.load{_ in }

        XCTAssertEqual(client.requestedUrls,[url])
        
    }
    
    func test_loadTwice_shouldRequestDataFromUrlTwice(){
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSut(url: url)
        
        
        sut.load{_ in }
        sut.load{_ in }
        
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
    
    func test_load_deliversErrorOnNon200HttpResponses(){
        let (sut,client) = makeSut()
        
        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index,code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load{capturedErrors.append($0)}
            
            client.complete(with: code,at: 0)
            
            XCTAssertEqual(capturedErrors,[.invalidData])
        }
       
        
        
    }
    
    
    
    
    
    
    // MARK: - Helpers
    
    private func makeSut(url:URL = URL(string: "https//google.com")!) -> (RemoteFeedLoader,HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)
        
        return (sut,client)
        
    }
    
    class HttpClientSpy:HttpClient{
        
        var messages = [(url: URL, completion:(HTTPURLResponse?,Error?) -> Void)]()
        
        var requestedUrls:[URL]{
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping (HTTPURLResponse?,Error?) -> Void) {
            messages.append((url,completion))
            
        }
        
        func complete(with error:Error,at index:Int = 0){
            messages[index].completion(nil,error)
        }
        
        func complete(with statusCode:Int,at index:Int = 0){
            let response = HTTPURLResponse(url: messages[index].url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
            
            messages[index].completion(response,nil)
        }

    }
}
