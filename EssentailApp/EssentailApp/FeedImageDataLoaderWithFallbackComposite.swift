//
//  FeedLoaderWithFallbackComposite.swift
//  EssentailApp
//
//  Created by macbook abdul on 16/06/2024.
//

import Foundation
import EssentialFeed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary:FeedImageDataLoader
    private let fallback:FeedImageDataLoader
    
    private class Task: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?

        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task()
        task.wrapped = primary.loadImageData(from: url) { [weak self ]result in
            guard self != nil else{return}
            switch result {
            case .success(_):
                completion(result)
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: { result in
                    completion(result)
                })
            }
        }
        return task
    }
    
}
