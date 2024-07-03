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
    
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    private let selection: (FeedImage) -> Void

    weak var feedViewController: ListViewController?
    let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(feedViewController: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,selection: @escaping (FeedImage) -> Void) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feed:[CellController] =  viewModel.items.map({
            model in
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
            
            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model), delegate: adapter,selection: { [selection] in
                selection(model)
            })
            
            let presenter = LoadResourcePresenter(loadingView: WeakRefVirtualProxy(view), errorView: WeakRefVirtualProxy(view), resourceView: WeakRefVirtualProxy(view),mapper:UIImage.tryMake)
            adapter.presenter = presenter
            return CellController(id: model, view) 
        })
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            feedViewController?.display(feed)
            return
        }

        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
                    resourceView: self,
                    loadingView: WeakRefVirtualProxy(loadMore),
                    errorView: WeakRefVirtualProxy(loadMore))

        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        feedViewController?.display(feed, loadMoreSection)

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

