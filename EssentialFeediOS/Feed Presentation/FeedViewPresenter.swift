//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed


protocol FeedLoadingView{
    func display(_ viewModel:FeedLoadingViewModel)
}

protocol FeedView{
    func display(_ viewModel:FeedViewModel)
}
class FeedPresenter {
    
    let feedLoadingView:FeedLoadingView
    let feedView:FeedView

    static var title: String {
       return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(
                for:FeedPresenter.self
            ) ,
            comment: "Title for the feed view"
        )
        
    }
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed(){
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed :[FeedImage]){
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))

    }
    func didFinishLoadingFeed(with: Error) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
}
