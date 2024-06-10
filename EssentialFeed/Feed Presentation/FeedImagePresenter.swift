//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation



public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel:FeedImageViewModel<Image>)

}
public class FeedImagePresenter<View:FeedImageView,Image> where View.Image == Image {
    private let view:View
    private let imageTransformer:(Data) -> Image?

    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
     
    
    public func didStartLoadingImageData(for model: FeedImage) {
         view.display(FeedImageViewModel(
            location: model.location, description: model.description,
             image: nil,
             isLoading: true,
             shouldRetry: false))
     }

    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)

        view.display(FeedImageViewModel(
           location: model.location, description: model.description,
            image: imageTransformer(data),
            isLoading: false,
            shouldRetry: image == nil))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        
        view.display(FeedImageViewModel(
           location: model.location, description: model.description,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
