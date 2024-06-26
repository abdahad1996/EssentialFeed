//
//  FeedCacheTestsHelper.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 15/04/2024.
//

import Foundation
import XCTest
import EssentialFeed

func uniqueImages() -> (
    models:[FeedImage],
    local:[LocalFeedImage]
){
    let models = [uniqueImage(),uniqueImage()]
    let local = models.map{LocalFeedImage(id: $0.id,description: $0.description,location: $0.location, imageURL: $0.url)}
    
    return (models,local)
}


extension Date{
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    private var feedCacheMaxAgeInDays:Int {
        return 7
    }
}

