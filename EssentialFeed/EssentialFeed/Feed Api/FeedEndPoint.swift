//
//  FeedEndPoint.swift
//  EssentialFeed
//
//  Created by macbook abdul on 01/07/2024.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
