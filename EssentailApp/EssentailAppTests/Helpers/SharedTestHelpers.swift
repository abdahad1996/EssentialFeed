//
//  Helpers.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 11/06/2024.
//

import Foundation
import EssentialFeed

 func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)
}
  func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
  func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
func anyData() -> Data {
        return Data("any data".utf8)
    }

 func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
