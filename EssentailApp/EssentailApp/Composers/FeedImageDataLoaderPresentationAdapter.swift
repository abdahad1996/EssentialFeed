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

class FeedImageDataLoaderPresentationAdapter<View:FeedImageView,Image>:FeedImageCellControllerDelegate where View.Image == Image {
    private var task:FeedImageDataLoaderTask?
    let imageLoader:(URL) -> FeedImageDataLoader.Publisher
    let model:FeedImage
    var presenter:FeedImagePresenter<View,Image>?
    private var cancellable:Cancellable?
    
    init(model:FeedImage, imageLoader:@escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage(){
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
            switch result {
            case .finished:
                break
            case .failure(let error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }, receiveValue: { [weak self] data in
            self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        })
        
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        }
}
