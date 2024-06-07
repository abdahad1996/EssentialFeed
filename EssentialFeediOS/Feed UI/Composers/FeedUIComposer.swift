//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init(){}
    
    
    public static func feedComposedWith(
        loader: FeedLoader,
        imageLoader:FeedImageLoader
    ) -> FeedViewController{
        
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(loader: MainDispatchQueueDecorator(decoratee:loader))
        let feedController = FeedViewController.makeWith(delegate: feedLoaderPresentationAdapter, title: FeedPresenter.title)
        

        feedLoaderPresentationAdapter.presenter = FeedPresenter(feedLoadingView: WeakRefVirtualProxy(feedController), feedView: FeedViewAdapter(feedViewController: feedController, imageLoader: MainDispatchQueueDecorator(decoratee:imageLoader)))

      return feedController
    }
    
}


private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}



class FeedViewAdapter:FeedView{
    
    weak var feedViewController: FeedViewController?
    let imageLoader:  FeedImageLoader
    
    init(feedViewController:FeedViewController,imageLoader: FeedImageLoader) {
        self.imageLoader = imageLoader
        self.feedViewController = feedViewController
    }
    
    func display(_ viewModel: FeedViewModel) {
        
        feedViewController?.tableModel = viewModel.feed.map({
            feed in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: feed, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            let presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), transformer: UIImage.init)
            adapter.presenter = presenter
            return view
        })
    }
    
}


