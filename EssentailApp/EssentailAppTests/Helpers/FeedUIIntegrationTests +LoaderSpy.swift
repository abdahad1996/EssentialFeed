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
    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
    var loadFeedCallCount :Int {
        return feedRequests.count
    }
     
    
//    func load(completion: @escaping (FeedLoader.Result) -> Void) {
//        feedRequests.append(completion)
//    }
    
    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>,Error>{
        let passthroughSubject = PassthroughSubject<Paginated<FeedImage>,Error>()
        feedRequests.append(passthroughSubject)
        return passthroughSubject.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed:[FeedImage] = [],at index:Int = 0){
//        feedRequests[index](.success(feed))
        feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
                        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                        self?.loadMoreRequests.append(publisher)
                        return publisher.eraseToAnyPublisher()
                    }))
        feedRequests[index].send(completion: .finished)

    }
    
    func completeFeedLoadingWithError(at index:Int = 0){
        let error = NSError(domain: "an error", code: 2)
        feedRequests[index].send(completion: .failure(error))

//        feedRequests[index](.failure(error))
    }
    
    // MARK: - LoadMoreFeedLoader
    
    private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
    
    var loadMoreCallCount: Int {
        return loadMoreRequests.count
    }
    
    func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
        loadMoreRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
        loadMoreRequests[index].send(Paginated(
                                        items: feed,
                                        loadMorePublisher: lastPage ? nil : { [weak self] in
                                            self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                                        }))
    }
    
    func completeLoadMoreWithError(at index: Int = 0) {
        loadMoreRequests[index].send(completion: .failure(anyNSError()))
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

