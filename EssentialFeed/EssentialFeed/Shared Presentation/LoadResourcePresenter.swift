//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}
final public class LoadResourcePresenter<Resource,View:ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let loadingView:FeedLoadingView
    private let errorView: FeedErrorView
    private let resourceView:View
    private let mapper:Mapper
    
    var feedLoadError = NSLocalizedString(
        "FEED_VIEW_CONNECTION_ERROR",
        tableName: "Feed",
        bundle: Bundle(
            for:FeedPresenter.self
        ) ,
        comment: "Error message displayed when image feed fail to load from the server"
    )
    
    public init(loadingView: FeedLoadingView, errorView: FeedErrorView, resourceView: View,mapper:@escaping Mapper) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.resourceView = resourceView
        self.mapper = mapper
    }

    
    public func didStartLoading(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource :Resource){
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: FeedPresenter.feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
