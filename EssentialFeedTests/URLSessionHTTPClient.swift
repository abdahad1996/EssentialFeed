//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
struct UnexpectedValuesRepresentation: Error {}

class URLSessionHTTPClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()

    }
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    func test_getFromURL_perfromsGetRequestWithURL(){
        let url = anyURL()
        URLProtocolStub.stub(data:nil,response:nil, error: nil)
        
        let exp = expectation(description: "Wait for completion")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()

        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    func test_getFromURL_failsOnRequestError() {
        let url = anyURL()
        let requestError = NSError(domain: "any error", code: 0)
        URLProtocolStub.stub(data:nil,response:nil, error: requestError)
        
       
        
       let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCase(){
        let anyData = Data("any data".utf8)
        let anyError = NSError(domain: "any error", code: 0)
        let nonHTTPURLResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHTTPURLResponse =  HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyError))

    }
    
    // MARK: - Helpers
    private func resultErrorFor(data:Data?,response:URLResponse?,error:Error?) -> Error?{
        URLProtocolStub.stub(data:nil,response:nil, error: error)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedError:Error?
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(error ):
                receivedError = error
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }

        wait(for: [exp],timeout: 1)
        return receivedError
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        let url = URL(string: "http://any-url.com")!
        return url
    }
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver : ((URLRequest) -> Void)?
        private struct Stub {
            let data:Data?
            let response:URLResponse?
            let error: Error?
            
            
        }
        
        static func stub(data:Data?,response:URLResponse?, error: Error? ) {
            stub = Stub(data: data,response:response,error:error)
        }
        static func observeRequests(observer:@escaping (URLRequest) -> Void){
            requestObserver = observer
        }
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
           requestObserver?(request)
           return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response,cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
