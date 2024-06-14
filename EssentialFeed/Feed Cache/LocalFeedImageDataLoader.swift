//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 14/06/2024.
//

import Foundation

public class LocalFeedImageDataLoader {
    let store:FeedImageDataStore
    public init(store:FeedImageDataStore){
        self.store = store
    }
    public enum Error:Swift.Error{
        case failed
        case notFound
    }
    
    private final class Task:FeedImageDataLoaderTask{
    var completion:((FeedImageDataLoader.Result) -> Void)?
        
        init(completion:@escaping (FeedImageDataLoader.Result) -> Void ) {
            self.completion = completion
        }
        func cancel() {
            self.completion = nil
        }
        func complete(with completion:FeedImageDataLoader.Result){
            self.completion?(completion)
        }
    }
    
    public func loadImageData(from url: URL,completion:@escaping(FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url) {[weak self] result in
            guard self != nil else{return}

            switch result {
            case .success(let data):
                if let data = data {
                    task.complete(with:.success(data))
                 }else{
                     task.complete(with:.failure(Error.notFound))
                }
            case .failure:
                task.complete(with:.failure(Error.failed))
                
                }
            }
        return task
    }
}
