//
//  Helpers.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 11/06/2024.
//

import Foundation
import EssentialFeed

func anyUrl() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyError() -> NSError {
    return NSError(domain: "any error", code: 0, userInfo: nil)
}

func uniqueImage() -> FeedImage{
    return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyUrl())
}
