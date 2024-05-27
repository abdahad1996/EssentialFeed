//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    private init(){}
    
    
    public static func feedComposedWith(loader: FeedLoader,imageLoader:FeedImageLoader) -> FeedViewController{
        let refreshController = FeedRefreshViewController(feedLoader: loader)

        let feedViewController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(feedViewController, imageLoader)
      return feedViewController
    }
    
    private static func adaptFeedToCellControllers(_ feedViewController: FeedViewController, _ imageLoader: any FeedImageLoader) -> ([FeedImage]) -> Void {
        return { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map({ feed in
                return FeedImageCellController(model: feed, imageLoader:imageLoader)
            })
            
        }
    }
}
