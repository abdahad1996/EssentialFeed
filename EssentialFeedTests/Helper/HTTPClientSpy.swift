//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation
import EssentialFeed

class HTTPClientSpy:HTTPClient {
    
    private struct Task:HTTPClientTask{
        let callBack:() -> Void
        func cancel(){
            callBack()
        }
    }
   private var completions = [(url:URL,completion:(HTTPClient.Result) -> Void)]()
    
    var requestedUrls:[URL] {
        completions.map {$0.url}
    }
    
    var cancelledURLs = [URL]()
    
    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completions.append((url:url,completion:completion))
        return Task(callBack: { [weak self] in
            self?.cancelledURLs.append(url)
        })
    }
    
    func complete(with error:Error,at index:Int = 0) {
        completions[index].completion(.failure(error))
    }
    
    func complete(with data:Data,statusCode:Int,at index:Int = 0) {
        let response = HTTPURLResponse(url: requestedUrls[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        completions[index].completion(.success((data, response)))
    }
    
}




