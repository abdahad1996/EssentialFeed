//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation

//public protocol FeedImageDataLoaderTask {
//    func cancel()
//}
public protocol FeedImageDataLoader {
//    typealias Result = Swift.Result<Data,Error>
//    func loadImageData(from url: URL,completion:@escaping(Result) -> Void) -> FeedImageDataLoaderTask
    func loadImageData(from url: URL) throws -> Data

    
}


