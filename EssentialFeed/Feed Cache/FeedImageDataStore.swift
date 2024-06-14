//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 14/06/2024.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?,Error>
    func retrieve(dataForURL url: URL,completion:@escaping (Result) -> Void )
    
    typealias InsertionResult = Swift.Result<Void, Error>
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}


