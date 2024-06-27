//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

import UIKit

public final class FeedUIComposer {
    private init(){}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader:@escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader:@escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> ListViewController{
      
        let loadResourcePresentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let feedController = makeFeedViewController(delegate: loadResourcePresentationAdapter, title: FeedPresenter.title)
        
      
        loadResourcePresentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(
                feedController
            ),
            errorView: WeakRefVirtualProxy(
                feedController
            ),
            resourceView: FeedViewAdapter(
                feedViewController: feedController,
                imageLoader:imageLoader
            ), mapper: FeedPresenter.map
        )
        
        return feedController
    }
    
    
    
    
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> ListViewController{
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
    
    
    
}
