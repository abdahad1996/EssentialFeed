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


class FeedViewAdapter:ResourceView{
    
    weak var feedViewController: FeedViewController?
    let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(feedViewController: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        feedViewController?.display(viewModel.feed.map({
            model in
            
            let adapter = LoadResourcePresentationAdapter<Data,WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
//            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            
            let view = FeedImageCellController(delegate: adapter, viewModel: FeedImagePresenter<FeedImageCellController,UIImage>.map(model))
            
//            let presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            let presenter = LoadResourcePresenter(loadingView: WeakRefVirtualProxy(view), errorView: WeakRefVirtualProxy(view), resourceView: WeakRefVirtualProxy(view)) { data in
                guard let image = UIImage(data: data) else {
                    throw InvalidImageData()
                }
                return image
            }
            adapter.presenter = presenter
            return view
        }))
        
    }
    
}

private struct InvalidImageData: Error {}

