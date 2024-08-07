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
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let loadingView:ResourceLoadingView
    private let errorView: ResourceErrorView
    private let resourceView:View
    private let mapper:Mapper
    
    public static var loadError: String {
        NSLocalizedString("GENERIC_CONNECTION_ERROR",
                          tableName: "Shared",
                          bundle: Bundle(for: Self.self),
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    public init(loadingView: ResourceLoadingView, errorView: ResourceErrorView, resourceView: View,mapper:@escaping Mapper) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView) where Resource == View.ResourceViewModel {
            self.resourceView = resourceView
            self.loadingView = loadingView
            self.errorView = errorView
            self.mapper = { $0 }
        }

    
    public func didStartLoading(){
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource :Resource){
        do {
            resourceView.display(try mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        }catch {
            didFinishLoadingFeed(with: error)
        }
         
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
