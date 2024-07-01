//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 01/07/2024.
//

import Foundation
import EssentialFeed
import XCTest

class FeedEndpointTests: XCTestCase {
    
    func test_feed_endpointURL() {
            let baseURL = URL(string: "http://base-url.com")!

            let received = FeedEndpoint.get.url(baseURL: baseURL)
            let expected = URL(string: "http://base-url.com/v1/feed")!

            XCTAssertEqual(received, expected)
        }
    
}
