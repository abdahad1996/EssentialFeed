//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation


final public class LoadResourcePresenter {
    
    private let feedLoadingView:FeedLoadingView
    private let errorView: FeedErrorView
    private let feedView:FeedView
    
     static var feedLoadError = NSLocalizedString(
        "FEED_VIEW_CONNECTION_ERROR",
        tableName: "Feed",
        bundle: Bundle(
            for:FeedPresenter.self
        ) ,
        comment: "Error message displayed when image feed fail to load from the server"
    )
    
    public init(feedLoadingView: FeedLoadingView, errorView: FeedErrorView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.errorView = errorView
        self.feedView = feedView
    }
    
    public func didStartLoadingFeed(){
        errorView.display(.noError)
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed :[FeedImage]){
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: FeedPresenter.feedLoadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}