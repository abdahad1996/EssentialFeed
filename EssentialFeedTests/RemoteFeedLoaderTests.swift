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
        
        expect(sut, toCompletewith: .failure(.connectivity),when : {
            let clientError = NSError(domain: "", code: 1)
            client.complete(with: clientError)
        })
        
        
    }
    
    func test_load_deliversErrorOnNon200HttpResponses(){
        let (sut,client) = makeSut()
        
        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index,code in
            expect(sut, toCompletewith: .failure(.invalidData) ,when : {
                client.complete(with: code,at: index)
            })
             
            
        }
       
    }
    
    func test_load_deliversErronOn200HttpUrlResponseWithInvalidJson(){
        
        let (sut,client) = makeSut()
        
        expect(sut, toCompletewith: .failure(.invalidData),when:  {
            let InvalidJson = Data("Invalid Json".utf8)
            client.complete(with: 200,data:InvalidJson)
        })
        
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        
        let (sut,client) = makeSut()
        
        expect(sut, toCompletewith: .success([]),when :{
            let emptyJson = Data("{\"items\": []}".utf8)
            client.complete(with: 200, data: emptyJson)
        })
      
        
        
    }
    
    
    
    
    
    
    // MARK: - Helpers
    
    private func makeSut(url:URL = URL(string: "https//google.com")!) -> (RemoteFeedLoader,HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)
        
        return (sut,client)
        
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompletewith result:RemoteFeedLoader.Result,
        when action:()->Void,
        file: StaticString = #file,
        line:UInt = #line
    ){
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load{capturedResults.append($0)}
        
        action()
       
        
        XCTAssertEqual(capturedResults,[result],file:file,line:line)
    }
    
    class HttpClientSpy:HttpClient{
        
        var messages = [(url: URL, completion:(HttpClientResult) -> Void)]()
        
        var requestedUrls:[URL]{
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
            messages.append((url,completion))
            
        }
        
        func complete(with error:Error,at index:Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode:Int,data:Data = Data(),at index:Int = 0){
            let response = HTTPURLResponse(url: messages[index].url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(.success(data,response))
        }

    }
}
