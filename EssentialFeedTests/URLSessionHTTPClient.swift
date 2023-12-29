//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by Abdul Ahad on 29.12.23.
//

import Foundation
import XCTest

class URLSessionHttpClient{
    let session : URLSession
    
    init(session:URLSession) {
        self.session = session
    }
    func get(from url:URL){
        session.dataTask(with: url){_,_,_ in}.resume()
    }
    
}
class URLSessionHTTPClient:XCTestCase{
 
    
    func test_getFromURL_resumesDataTaskWithURL(){
        let url = URL(string:"http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHttpClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount,1)
        
        
    }
    
    class URLSessionSpy:URLSession{
        private var stubs = [URL: URLSessionDataTask]()

        func stub(url:URL,task:URLSessionDataTask){
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
        }
    
    class FakeURLSessionDataTask:URLSessionDataTask{}
    class URLSessionDataTaskSpy:URLSessionDataTask{
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
}
