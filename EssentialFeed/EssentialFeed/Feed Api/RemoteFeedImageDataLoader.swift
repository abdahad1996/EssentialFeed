//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation

public class RemoteFeedImageDataLoader:FeedImageDataLoader {
    let client:HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private class HTTPTaskWrapper: FeedImageDataLoaderTask {
        
        var wrapped:HTTPClientTask?
        var completion:((FeedImageDataLoader.Result) -> Void)?
        
        init(completions: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completions
        }
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
            
        }
        func complete(with result:FeedImageDataLoader.Result){
            completion?(result)
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL,completion:@escaping(FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completions: completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else{return}
            switch result{
            case let .success((data,response)):
                if !response.isOK || data.isEmpty {
                    task.complete(with:.failure(Error.invalidData))
                }else{
                    task.complete(with:.success(data))
                    
                }
                
            case .failure:
                task.complete(with:.failure(Error.connectivity))
            }
            
        }
        
        return task
    }
}
