import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests:XCTestCase{
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
        
        expect(sut, toCompletewith: failure(RemoteImageCommentsLoader.Error.connectivity),when : {
            let clientError = NSError(domain: "", code: 1)
            client.complete(with: clientError)
        })
        
        
    }
    
    func test_load_deliversErrorOnNon2xxHTTPResponse(){
        let (sut,client) = makeSut()
        
        let samples = [199,150,300,400,500]
        samples.enumerated().forEach { index,code in
            expect(sut, toCompletewith: failure(RemoteImageCommentsLoader.Error.invalidData) ,when : {
                let emptyJson = makeItemsJSON([])
                client.complete(with: emptyJson, statusCode: code,at:index)
                
            })
             
            
        }
       
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON(){
        
        let (sut,client) = makeSut()
        let samples = [200, 201, 250, 280, 299]
        samples.enumerated().forEach { index,code in
            
            expect(sut, toCompletewith: failure(RemoteImageCommentsLoader.Error.invalidData),when:  {
                let InvalidJson = Data("Invalid Json".utf8)
                client.complete(with: InvalidJson, statusCode: code,at:index)

            })
            
        }
        
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList(){
        
        let (sut,client) = makeSut()
        let samples = [200, 201, 250, 280, 299]
        samples.enumerated().forEach { index,code in
            
            expect(sut, toCompletewith: .success([]), when: {
                let emptyListJSON = makeItemsJSON([])
                client.complete(with: emptyListJSON, statusCode: code,at: index)
                      })
        }
        
      
        
    }
    

    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems(){
        let (sut,client) = makeSut()

        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username")
        
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "a username")
        
        let samples = [200, 201, 250, 280, 299]
        samples.enumerated().forEach { index,code in
            
            let items = [item1.model, item2.model]
            expect(sut, toCompletewith: .success(items), when: {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(with: json, statusCode: code,at:index)
            })
            
        }

        
        
    }
    
    func test_load_doesNotCompleteAfterSutHasBeenDeallocated(){
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut:RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url:url, client: client)
        var captureResult = [RemoteImageCommentsLoader.Result]()
        sut?.load{captureResult.append($0)}
        
        sut = nil
        client.complete(with: makeItemsJSON([]), statusCode: 200)
        
        XCTAssertTrue(captureResult.isEmpty)

    }
    
    
    
    
    // MARK: - Helpers
    
    private func makeSut(url:URL = URL(string: "https//google.com")!,file: StaticString = #file, line: UInt = #line) -> (RemoteImageCommentsLoader,HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url:url, client: client)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(client,file: file,line: line)

        return (sut,client)
        
    }
    private func failure(_ error:RemoteImageCommentsLoader.Error)->RemoteImageCommentsLoader.Result{
        return .failure(error)
    }
    
    fileprivate func makeItem(id:UUID,message: String,createdAt:(date:Date,iso8601String:String),username:String) -> (model:ImageComment,json:[String:Any]) {
        
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": ["username":username]
        ].compactMapValues { $0 }
        

        return (item,json)
        
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut:RemoteImageCommentsLoader,toCompletewith expectedResult:RemoteImageCommentsLoader.Result,
        when action:()->Void,
        file: StaticString = #file,
        line:UInt = #line
    ){
        let exp = expectation(description: "Wait for load completion")
        sut.load { recievedResult in
            switch (recievedResult,expectedResult){
            case let (.success(recievedItems),.success(expectedItems)):
                XCTAssertEqual(recievedItems,expectedItems,file:file,line:line)
            case let (.failure(recievedError as RemoteImageCommentsLoader.Error),.failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(recievedError,expectedError,file:file,line:line)

            default:
                XCTFail("Expected result \(recievedResult) got \(expectedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
     }
    
    
}
