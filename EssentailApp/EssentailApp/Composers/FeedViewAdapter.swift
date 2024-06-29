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
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    weak var feedViewController: ListViewController?
    let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(feedViewController: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        feedViewController?.display(viewModel.feed.map({
            model in
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
//            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            
            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model), delegate: adapter)
            
//            let presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            let presenter = LoadResourcePresenter(loadingView: WeakRefVirtualProxy(view), errorView: WeakRefVirtualProxy(view), resourceView: WeakRefVirtualProxy(view),mapper:UIImage.tryMake)
            adapter.presenter = presenter
            return CellController(id: model, view) 
        }))
        
    }
   
}
extension UIImage {
    struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
private struct InvalidImageData: Error {}

