//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation



public protocol FeedView{
    func display(_ viewModel:FeedViewModel)
}

final public class FeedPresenter {
    
    private let loadingView:ResourceLoadingView
    private let errorView: ResourceErrorView
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
        "GENERIC_CONNECTION_ERROR",
        tableName: "Shared",
        bundle: Bundle(
            for:FeedPresenter.self
        ) ,
        comment: "Error message displayed when image feed fail to load from the server"
    )
    
    public init(loadingView: ResourceLoadingView, errorView: ResourceErrorView, feedView: FeedView) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.feedView = feedView
    }
    
    public func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed :[FeedImage]){
        feedView.display(Self.map(feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: FeedPresenter.feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ feed:[FeedImage]) -> FeedViewModel{
        FeedViewModel.init(feed: feed)
    }
}
