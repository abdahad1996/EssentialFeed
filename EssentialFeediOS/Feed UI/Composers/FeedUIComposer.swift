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
        let feedController = makeFeedViewController(delegate: feedLoaderPresentationAdapter, title: FeedPresenter.title)
        
        
        feedLoaderPresentationAdapter.presenter = FeedPresenter(feedLoadingView: WeakRefVirtualProxy(feedController), feedView: FeedViewAdapter(feedViewController: feedController, imageLoader: MainDispatchQueueDecorator(decoratee:imageLoader)))
        
        return feedController
    }
    
    
    
    
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController{
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
    
    
    
}
