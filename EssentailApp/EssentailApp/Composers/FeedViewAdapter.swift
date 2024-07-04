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
    private let currentFeed: [FeedImage: CellController]


    weak var feedViewController: ListViewController?
    let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(currentFeed: [FeedImage: CellController] = [:],feedViewController: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,selection: @escaping (FeedImage) -> Void) {
        self.currentFeed = currentFeed
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller = feedViewController else { return }
        var currentFeed = self.currentFeed


        let feed:[CellController] =  viewModel.items.map({
            model in
            if let controller = currentFeed[model] {
                            return controller
                        }
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            
            
            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model), delegate: adapter,selection: { [selection] in
                selection(model)
            })
            
            let presenter = LoadResourcePresenter(loadingView: WeakRefVirtualProxy(view), errorView: WeakRefVirtualProxy(view), resourceView: WeakRefVirtualProxy(view),mapper:UIImage.tryMake)
            adapter.presenter = presenter
            
            let controller = CellController(id: model, view)
            currentFeed[model] = controller
            return controller
        })
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feed)
            return
        }

        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
                    resourceView: FeedViewAdapter(currentFeed: currentFeed, feedViewController: controller, imageLoader: imageLoader, selection: selection),
                    loadingView: WeakRefVirtualProxy(loadMore),
                    errorView: WeakRefVirtualProxy(loadMore))

        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        controller.display(feed, loadMoreSection)

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

