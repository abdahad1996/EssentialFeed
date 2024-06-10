//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation

public struct FeedImageViewModel<Image>{
    public let location:String?
    public let description:String?
    public let image:Image?
    public let isLoading:Bool
    public let shouldRetry:Bool
    
    var hasLocation: Bool {
        return location != nil
    }
    
}


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
