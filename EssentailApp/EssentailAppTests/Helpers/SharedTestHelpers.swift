//
//  Helpers.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 11/06/2024.
//

import Foundation
import EssentialFeed



  func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
  func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
func anyData() -> Data {
        return Data("any data".utf8)
    }
