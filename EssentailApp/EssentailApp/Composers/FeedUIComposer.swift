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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader:@escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader:@escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController{
      
        let loadResourcePresentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let feedController = makeFeedViewController(title: FeedPresenter.title)
        feedController.onRefresh = loadResourcePresentationAdapter.loadResource
        
      
        loadResourcePresentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                feedViewController: feedController,
                imageLoader:imageLoader, selection: selection
            ), loadingView: WeakRefVirtualProxy(
                feedController
            ),
            errorView: WeakRefVirtualProxy(
                feedController
            )
        )
        
        return feedController
    }
    
    
    
    
    
    private static func makeFeedViewController(title: String) -> ListViewController{
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
    
    
    
}
