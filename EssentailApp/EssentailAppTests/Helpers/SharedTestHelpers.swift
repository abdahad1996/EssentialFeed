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

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }

    func adding(minutes: Int,calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int,calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}

private class DummyView:ResourceView{
    func display(_ viewModel: String){}
}
var feedTitle:String{
    FeedPresenter.title
}

var loadError:String{
    LoadResourcePresenter<Any,DummyView>.loadError
}

var commentsTitle: String {
        ImageCommentsPresenter.title
    }
