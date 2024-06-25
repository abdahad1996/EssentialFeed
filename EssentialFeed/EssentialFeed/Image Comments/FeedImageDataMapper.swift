//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 23.12.23.
//

import Foundation

public final class FeedImageDataMapper{
    private init(){}
    
    public enum Error: Swift.Error {
            case invalidData
        }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> Data{
       guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }
        return data
    }
}

