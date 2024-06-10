//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedLoadingView{
    func display(_ viewModel:FeedLoadingViewModel)
}

protocol FeedView{
    func display(_ viewModel:FeedViewModel)
}
class FeedPresenter {
    
    let feedLoadingView:FeedLoadingView
    let feedView:FeedView
    private let errorView: FeedErrorView


    static var feedTitle: String {
       return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(
                for:FeedPresenter.self
            ) ,
            comment: "Title for the feed view"
        )
        
    }
    
    static var feedLoadError = NSLocalizedString(
        "FEED_VIEW_CONNECTION_ERROR",
        tableName: "Feed",
        bundle: Bundle(
            for:FeedPresenter.self
        ) ,
        comment: "Error message displayed when image feed fail to load from the server"
    )
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView,errorView:FeedErrorView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
        self.errorView = errorView
        
    }
    
    func didStartLoadingFeed(){
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
    
    func didFinishLoadingFeed(with feed :[FeedImage]){
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))

    }
    func didFinishLoadingFeed(with: Error) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(.error(message: FeedPresenter.feedLoadError))
    }
    
}
