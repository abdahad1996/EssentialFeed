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
        
        expect(sut, toCompletewith: failure(RemoteFeedLoader.Error.connectivity),when : {
            let clientError = NSError(domain: "", code: 1)
            client.complete(with: clientError)
        })
        
        
    }
    
    func test_load_deliversErrorOnNon200HttpResponses(){
        let (sut,client) = makeSut()
        
        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index,code in
            expect(sut, toCompletewith: failure(RemoteFeedLoader.Error.invalidData) ,when : {
                let emptyJson = makeItemsJSON([])
                client.complete(with: code,data:emptyJson ,at: index)
            })
             
            
        }
       
    }
    
    func test_load_deliversErronOn200HttpUrlResponseWithInvalidJson(){
        
        let (sut,client) = makeSut()
        
        expect(sut, toCompletewith: failure(RemoteFeedLoader.Error.invalidData),when:  {
            let InvalidJson = Data("Invalid Json".utf8)
            client.complete(with: 200,data:InvalidJson)
        })
        
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        
        let (sut,client) = makeSut()
        
        expect(sut, toCompletewith: .success([]),when :{
            let emptyJson = makeItemsJSON([])
            client.complete(with: 200, data: emptyJson)
        })
      
        
    }
    

    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems(){
        let (sut,client) = makeSut()

        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model, item2.model]
        expect(sut, toCompletewith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(with: 200,data: json)

        })
        
    }
    
    func test_load_doesNotCompleteAfterSutHasBeenDeallocated(){
        let url = URL(string: "http://a-url.com")!
        let client = HttpClientSpy()
        var sut:RemoteFeedLoader? = RemoteFeedLoader(url:url, client: client)
        var captureResult = [RemoteFeedLoader.Result]()
        sut?.load{captureResult.append($0)}
        
        sut = nil
        client.complete(with: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(captureResult.isEmpty)

    }
    
    
    
    
    // MARK: - Helpers
    
    private func makeSut(url:URL = URL(string: "https//google.com")!,file: StaticString = #file, line: UInt = #line) -> (RemoteFeedLoader,HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url:url, client: client)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(client,file: file,line: line)

        return (sut,client)
        
    }
    private func failure(_ error:RemoteFeedLoader.Error)->RemoteFeedLoader.Result{
        return .failure(error)
    }
    
    fileprivate func makeItem(id:UUID,description: String? = nil,location:String? = nil,imageURL:URL) -> (model:FeedImage,json:[String:Any]) {
        
        let item = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        

        return (item,json)
        
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompletewith expectedResult:RemoteFeedLoader.Result,
        when action:()->Void,
        file: StaticString = #file,
        line:UInt = #line
    ){
        let exp = expectation(description: "Wait for load completion")
        sut.load { recievedResult in
            switch (recievedResult,expectedResult){
            case let (.success(recievedItems),.success(expectedItems)):
                XCTAssertEqual(recievedItems,expectedItems,file:file,line:line)
            case let (.failure(recievedError as RemoteFeedLoader.Error),.failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(recievedError,expectedError,file:file,line:line)

            default:
                XCTFail("Expected result \(recievedResult) got \(expectedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
     }
    
    class HttpClientSpy:HTTPClient{
        
        var messages = [(url: URL, completion:(HTTPClient.Result) -> Void)]()
        
        var requestedUrls:[URL]{
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url,completion))
            
        }
        
        func complete(with error:Error,at index:Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode:Int,data:Data,at index:Int = 0){
            let response = HTTPURLResponse(url: messages[index].url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(.success((data,response)))
        }

    }
}
