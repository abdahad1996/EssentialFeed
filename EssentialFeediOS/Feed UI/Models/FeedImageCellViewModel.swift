//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed

public final class FeedImageCellViewModel{
    typealias Observer<T> = (T) -> Void
    private let model:FeedImage
    private var task:FeedImageDataLoaderTask?
    private let imageLoader: FeedImageLoader

    init(model: FeedImage, imageLoader: FeedImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var hasLocation:Bool{
        return location != nil
    }
    var location:String? {
         model.location
    }
    var description:String? {
         model.description
    }
    
    var onImageLoadingStateChange: Observer<Bool>?
    var onImageLoad: Observer<UIImage>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    func loadImageData() {
            onImageLoadingStateChange?(true)
            onShouldRetryImageLoadStateChange?(false)
            task = imageLoader.loadImageData(from: model.url) { [weak self] result in
                self?.handle(result)
            }
        }

        private func handle(_ result: Result<Data,Error>) {
            if let image = (try? result.get()).flatMap(UIImage.init) {
                onImageLoad?(image)
            } else {
                onShouldRetryImageLoadStateChange?(true)
            }
            onImageLoadingStateChange?(false)
        }
    
    func cancelImageDataLoad(){
        
        task?.cancel()
        task = nil
    }
}
