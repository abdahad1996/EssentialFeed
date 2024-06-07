//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS


//MARK: SPY
class loaderSpy:FeedLoader,FeedImageLoader{
    
    
    // MARK: - FeedLoader
    private var feedRequests = [(FeedLoader.Result) -> Void]()
    
    var loadFeedCallCount :Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed:[FeedImage] = [],at index:Int = 0){
        feedRequests[index](.success(feed))
    }
    
    func completionLoadingWithError(at index:Int = 0){
        let error = NSError(domain: "an error", code: 2)
        feedRequests[index](.failure(error))
    }
    
    // MARK: - FeedImageDataLoader
    
    private var imageRequests = [(url:URL,completion:(FeedImageLoader.Result) -> Void )]()
    
    var loadedImageURLs:[URL]{
        return imageRequests.map{$0.url}
    }
    private(set) var cancelledImageURLs = [URL]()
    
    
    private struct TaskSpy:FeedImageDataLoaderTask{
        public let cancelTask:() -> Void
        func cancel() {
            cancelTask()
        }
        
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        
        imageRequests.append((url,completion))
        
        return TaskSpy { [weak self ] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    func completeImageLoading(with imageData:Data = Data(),at index:Int) {
        imageRequests[index].completion(.success(imageData))
    }
    func completeImageLoadingWithError(at index:Int) {
        let error = NSError(domain: "any", code: 0)
        imageRequests[index].completion(.failure(error))
    }
    
}

