//
//  FeedCacheTestsHelper.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 15/04/2024.
//

import Foundation
import XCTest
import EssentialFeed

func uniqueImage() -> FeedImage{
    return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyUrl())
}

func uniqueImages() -> (
    models:[FeedImage],
    local:[LocalFeedImage]
){
    let models = [uniqueImage(),uniqueImage()]
    let local = models.map{LocalFeedImage(id: $0.id,description: $0.description,location: $0.location, imageURL: $0.url)}
    
    return (models,local)
}

func anyUrl() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyError() -> NSError {
    return NSError(domain: "any error", code: 0, userInfo: nil)
}

extension Date{
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    private var feedCacheMaxAgeInDays:Int {
        return 7
    }
    func adding(days:Int) -> Self {
        return Calendar(identifier: .gregorian).date(byAdding: .day,value: days,to: self)!
    }
    func adding(seconds:TimeInterval) -> Self {
        return self + seconds
    }
}
