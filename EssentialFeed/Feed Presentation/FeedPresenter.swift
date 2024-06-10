//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}
public protocol FeedLoadingView{
    func display(_ viewModel:FeedLoadingViewModel)
}
public protocol FeedView{
    func display(_ viewModel:FeedViewModel)
}

final public class FeedPresenter {
    
    private let feedLoadingView:FeedLoadingView
    private let errorView: FeedErrorView
    private let feedView:FeedView
    
    public static var title: String {
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
