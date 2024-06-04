//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed

//public final class FeedImageViewModel<Image>{
//    typealias Observer<T> = (T) -> Void
//    private let model:FeedImage
//    private var task:FeedImageDataLoaderTask?
//    private let imageLoader: FeedImageLoader
//    private let transformer:(Data) -> Image?
//
//    init(model: FeedImage, imageLoader: FeedImageLoader,transformer: @escaping (Data) -> Image?) {
//        self.model = model
//        self.imageLoader = imageLoader
//        self.transformer = transformer
//    }
//    
//    var hasLocation:Bool{
//        return location != nil
//    }
//    var location:String? {
//         model.location
//    }
//    var description:String? {
//         model.description
//    }
//    
//    var onImageLoadingStateChange: Observer<Bool>?
//    var onImageLoad: Observer<Image>?
//    var onShouldRetryImageLoadStateChange: Observer<Bool>?
//
//    func loadImageData() {
//            onImageLoadingStateChange?(true)
//            onShouldRetryImageLoadStateChange?(false)
//            task = imageLoader.loadImageData(from: model.url) { [weak self] result in
//                self?.handle(result)
//            }
//        }
//
//        private func handle(_ result: Result<Data,Error>) {
//            if let image = (try? result.get()).flatMap(transformer) {
//                onImageLoad?(image)
//            } else {
//                onShouldRetryImageLoadStateChange?(true)
//            }
//            onImageLoadingStateChange?(false)
//        }
//    
//    func cancelImageDataLoad(){
//        
//        task?.cancel()
//        task = nil
//    }
//}
