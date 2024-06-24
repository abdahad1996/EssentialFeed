//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

//MARK: SPY
class loaderSpy:FeedImageDataLoader{
    
    
    // MARK: - FeedLoader
//    private var feedRequests = [(FeedLoader.Result) -> Void]()
    private var feedRequests = [ PassthroughSubject<[FeedImage],Error>]()
    var loadFeedCallCount :Int {
        return feedRequests.count
    }
    
//    func load(completion: @escaping (FeedLoader.Result) -> Void) {
//        feedRequests.append(completion)
//    }
    
    func loadPublisher() -> AnyPublisher<[FeedImage],Error>{
        let passthroughSubject = PassthroughSubject<[FeedImage],Error>()
        feedRequests.append(passthroughSubject)
        return passthroughSubject.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed:[FeedImage] = [],at index:Int = 0){
//        feedRequests[index](.success(feed))
        feedRequests[index].send(feed)
    }
    
    func completeFeedLoadingWithError(at index:Int = 0){
        let error = NSError(domain: "an error", code: 2)
        feedRequests[index].send(completion: .failure(error))

//        feedRequests[index](.failure(error))
    }
    
    // MARK: - FeedImageDataLoader
    
    private var imageRequests = [(url:URL,completion:(FeedImageDataLoader.Result) -> Void )]()
    
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
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        
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

