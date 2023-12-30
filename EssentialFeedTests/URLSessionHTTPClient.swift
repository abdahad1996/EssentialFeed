//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by Abdul Ahad on 29.12.23.
//

import Foundation
import EssentialFeed
import XCTest

protocol HTTPSession{
   func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}
protocol HTTPSessionTask {
    func resume()
}

class URLSessionHttpClient{
    let session : HTTPSession
    
    init(session:HTTPSession) {
        self.session = session
    }
    func get(from url:URL,completion:@escaping (HttpClientResult) -> Void ){
        session.dataTask(with: url){_,_,error in
            if let error = error {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
}
class URLSessionHTTPClient:XCTestCase{
    
    
    func test_getFromURL_resumesDataTaskWithURL(){
        let url = URL(string:"http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHttpClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount,1)
        
    }
    
    func test_getFromURL_failsOnRequestError(){
        let url = URL(string:"http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task,error: error)
        
        
        
        let sut = URLSessionHttpClient(session: session)
        
        let exp = expectation(description: "wait for completion")
        sut.get(from: url){ result in
            switch result {
            case .failure(let receivedError):
                XCTAssertEqual(receivedError as NSError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp],timeout: 1)
    }
    
    class URLSessionSpy:HTTPSession{
        private var stubs = [URL: Stub]()
        private struct Stub {
            let task:HTTPSessionTask
            let error:Error?
        }
        
        func stub(url:URL,task:HTTPSessionTask = FakeURLSessionDataTask(),error:Error? = nil){
            stubs[url] = Stub(task: task, error: error)
        }
        
         func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else{
                fatalError("Couln't find stub for \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
        
    }
    
    class FakeURLSessionDataTask:HTTPSessionTask{
         func resume() {
        }
    }
    class URLSessionDataTaskSpy:HTTPSessionTask{
        var resumeCallCount = 0
         func resume() {
            resumeCallCount += 1
        }
    }
}
