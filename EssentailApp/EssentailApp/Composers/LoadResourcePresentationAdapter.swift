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

class LoadResourcePresentationAdapter<Resource,View:ResourceView> {
    var presenter:LoadResourcePresenter<Resource,View>?
    let loader:() -> AnyPublisher<Resource, Error>
    var cancellable:Cancellable?
    private var isLoading = false

    
    init( loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }
            presenter?.didStartLoading()
        isLoading = true
            cancellable = loader()
            .dispatchOnMainThread()
            .handleEvents(receiveCancel: { [weak self] in
                            self?.isLoading = false
                        })
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case let .failure(error):
                        self?.presenter?.didFinishLoadingFeed(with: error)
                    }
                    self?.isLoading = false
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                })
        }
}

//extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
//    func didRequestFeedRefresh() {
//        loadResource()
//    }
//}
extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate{
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    
}
