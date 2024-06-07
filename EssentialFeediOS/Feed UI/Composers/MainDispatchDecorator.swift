//
//  MainDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 07/06/2024.
//

import Foundation
import EssentialFeed

 class MainDispatchQueueDecorator<T> {
    
    let decoratee:T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.async(execute: completion)
            }

            completion()
        }
    
}
extension MainDispatchQueueDecorator:FeedImageLoader where T == FeedImageLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
    
    
    
}

extension MainDispatchQueueDecorator:FeedLoader where T == FeedLoader {
    func load(completion: @escaping (Result<[FeedImage],Error>) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
