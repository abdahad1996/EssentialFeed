//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed


protocol FeedLoadingView:AnyObject{
    func display(isLoading:Bool)
     
}

protocol FeedView{
    func display(feed:[FeedImage])
}
class FeedPresenter {
    private let feedLoader: FeedLoader
    weak var feedLoadingView:FeedLoadingView?
    var feedView:FeedView?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
//        onLoadingStateChange?(true)
        feedLoadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
             
            if let feed = try? result.get() {
//                self?.onFeedLoad?(feed)
                self?.feedView?.display(feed: feed)
            }
//            self?.onLoadingStateChange?(false)
            self?.feedLoadingView?.display(isLoading: false)

        }
    }
}
