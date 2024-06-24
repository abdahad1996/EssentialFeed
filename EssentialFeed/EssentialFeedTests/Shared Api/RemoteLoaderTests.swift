////
////  RemoteFeedLoaderTests.swift
////  EssentialFeedTests
////
////  Created by Abdul Ahad on 18.12.23.
////
//
//import XCTest
//import EssentialFeed
//
//class RemoteLoaderTests:XCTestCase{
//    func test_init_doesNotRequestDataFromUrl(){
//        let (_,client) = makeSut()
//        XCTAssertTrue(client.requestedUrls.isEmpty)
//    }
//    
//    func test_load_shouldRequestDataFromUrl(){
//        let url = URL(string: "https://a-given-url.com")!
//        let (sut,client) = makeSut(url: url)
//        
//        
//        sut.load{_ in }
//
//        XCTAssertEqual(client.requestedUrls,[url])
//        
//    }
//    
//    func test_loadTwice_shouldRequestDataFromUrlTwice(){
//        let url = URL(string: "https://a-given-url.com")!
//        let (sut,client) = makeSut(url: url)
//        
//        
//        sut.load{_ in }
//        sut.load{_ in }
//        
//        XCTAssertEqual(client.requestedUrls,[url,url])
//        
//    }
//    
//    func test_load_deliversErrorOnMapperError(){
//        let (sut,client) = makeSut { data, response in
//            throw anyNSError()
//        }
//        
//        expect(sut, toCompletewith: failure(.invalidData)) {
//            client.complete(with:anyData(),statusCode: 200)
//        }
//        
//        
//    }
//    
//    func test_load_deliversMappedResource() {
//        let resource = "a resource"
//        
//        let (sut, client) = makeSut { data, _ in
//            String(data: data, encoding: .utf8)!
//        }
//        
//        expect(sut, toCompletewith: .success(resource), when: {
//         client.complete(with:Data(resource.utf8),statusCode: 200)
//        })
//        
//    }
//    
//    
//    func test_load_doesNotCompleteAfterSutHasBeenDeallocated(){
//        let url = URL(string: "http://a-url.com")!
//        let client = HTTPClientSpy()
//        var sut:RemoteLoader? = RemoteLoader<String>(url:url, client: client, mapper: { _,_ in
//            return "any"
//        })
//        
//        var captureResult = [RemoteLoader<String>.Result]()
//        sut?.load{captureResult.append($0)}
//        
//        sut = nil
//        client.complete(with: makeItemsJSON([]), statusCode: 200)
//        
//        XCTAssertTrue(captureResult.isEmpty)
//
//    }
//    
//    // MARK: - Helpers
//    
//    private func makeSut(url:URL = URL(string: "https//google.com")!,mapper:@escaping RemoteLoader<String>.Mapper = {_,_ in "any"},file: StaticString = #file, line: UInt = #line) -> (RemoteLoader<String>,HTTPClientSpy){
//        let client = HTTPClientSpy()
//        let sut = RemoteLoader<String>(url:url, client: client, mapper: mapper)
//        trackForMemoryLeaks(sut,file: file,line: line)
//        trackForMemoryLeaks(client,file: file,line: line)
//
//        return (sut,client)
//        
//    }
//    private func failure(_ error:RemoteLoader<String>.Error)->RemoteLoader<String>.Result{
//        return .failure(error)
//    }
//    
//    fileprivate func makeItem(id:UUID,description: String? = nil,location:String? = nil,imageURL:URL) -> (model:FeedImage,json:[String:Any]) {
//        
//        let item = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
//        
//        let json = [
//            "id": id.uuidString,
//            "description": description,
//            "location": location,
//            "image": imageURL.absoluteString
//        ].compactMapValues { $0 }
//        
//
//        return (item,json)
//        
//    }
//    
//    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
//        let json = ["items": items]
//        return try! JSONSerialization.data(withJSONObject: json)
//    }
//    
//    private func expect(_ sut:RemoteLoader<String>,toCompletewith expectedResult:RemoteLoader<String>.Result,
//        when action:()->Void,
//        file: StaticString = #file,
//        line:UInt = #line
//    ){
//        let exp = expectation(description: "Wait for load completion")
//        sut.load { recievedResult in
//            switch (recievedResult,expectedResult){
//            case let (.success(recievedItems),.success(expectedItems)):
//                XCTAssertEqual(recievedItems,expectedItems,file:file,line:line)
//            case let (.failure(recievedError as RemoteLoader<String>.Error),.failure(expectedError as RemoteLoader<String>.Error)):
//                XCTAssertEqual(recievedError,expectedError,file:file,line:line)
//
//            default:
//                XCTFail("Expected result \(recievedResult) got \(expectedResult) instead", file: file, line: line)
//                
//            }
//            exp.fulfill()
//        }
//        
//        action()
//        wait(for: [exp], timeout: 1.0)
//        
//     }
//    
//    
//}
