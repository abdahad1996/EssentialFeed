//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 14/06/2024.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?,Error>
    func retrieve(dataForURL url: URL,completion:@escaping (RetrievalResult) -> Void )
    
    typealias InsertionResult = Swift.Result<Void, Error>
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}


