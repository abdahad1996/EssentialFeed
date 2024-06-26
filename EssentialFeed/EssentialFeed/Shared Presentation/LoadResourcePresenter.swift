//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation




public protocol ResourceView {
    func display(_ viewModel: String)
}

final public class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    
    private let loadingView:FeedLoadingView
    private let errorView: FeedErrorView
    private let resourceView:ResourceView
    private let mapper:Mapper
    
     static var feedLoadError = NSLocalizedString(
        "FEED_VIEW_CONNECTION_ERROR",
        tableName: "Feed",
        bundle: Bundle(
            for:FeedPresenter.self
        ) ,
        comment: "Error message displayed when image feed fail to load from the server"
    )
    
    public init(loadingView: FeedLoadingView, errorView: FeedErrorView, resourceView: ResourceView,mapper:@escaping Mapper) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    public func didStartLoading(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource :String){
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: FeedPresenter.feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
