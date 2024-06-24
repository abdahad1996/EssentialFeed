//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 07/06/2024.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

class FeedLoaderPresentationAdapter:FeedViewControllerDelegate {
    
    var presenter:FeedPresenter?
    let feedLoader:() -> AnyPublisher<[FeedImage], Error>
    var cancellable:Cancellable?
    
    init( feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
            presenter?.didStartLoadingFeed()

            cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case let .failure(error):
                        self?.presenter?.didFinishLoadingFeed(with: error)
                    }
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
                })
        }
}
