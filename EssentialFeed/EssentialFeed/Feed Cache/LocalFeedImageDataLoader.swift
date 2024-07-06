//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by macbook abdul on 14/06/2024.
//

import Foundation

public class LocalFeedImageDataLoader:FeedImageDataLoader {
    let store:FeedImageDataStore
    public init(store:FeedImageDataStore){
        self.store = store
    }
    
    public enum LoadError:Swift.Error{
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
        task.complete(
            with: Swift.Result {
                try store.retrieve(dataForURL: url)
            }    .mapError { _ in LoadError.failed}
                    .flatMap { data in
                        data.map { .success($0) } ?? .failure(LoadError.notFound)
                    })

                return task

            }


        
        
//        store.retrieve(dataForURL: url) {[weak self] result in
//            guard self != nil else{return}
//
//            switch result {
//            case .success(let data):
//                if let data = data {
//                    task.complete(with:.success(data))
//                 }else{
//                     task.complete(with:.failure(Error.notFound))
//                }
//            case .failure:
//                task.complete(with:.failure(Error.failed))
//                
//                }
//            }
//        return task
//    }
    
    
}

extension LocalFeedImageDataLoader:FeedImageDataCache{
    public typealias SaveResult = FeedImageDataCache.Result

    public enum SaveError:Swift.Error{
        case failed
    }
 
        public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            
            completion(SaveResult {
                try store.insert(data, for: url)
            }.mapError { _ in SaveError.failed })

            
//            store.insert(data, for: url) { [weak self] result in
//                guard self != nil else{return }
//
//                switch result {
//                case .failure:
//                    completion(.failure(SaveError.failed))
//                case .success:
//                    completion(.success(Void()))
//                }
//            }
            
        }
}
