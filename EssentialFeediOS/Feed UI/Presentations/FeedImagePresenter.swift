//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image>{
    let location:String?
    let description:String?
    let image:Image?
    let isLoading:Bool
    let shouldRetry:Bool
    
    var hasLocation: Bool {
        return location != nil
    }
    
}
protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel:FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View:FeedImageView,Image> where View.Image == Image{
    private let view:View
    private let transformer:(Data) -> Image?

     init(view: View, transformer: @escaping (Data) -> Image?) {
         self.view = view
         self.transformer = transformer
     }
    
    
    func didStartLoadingImageData(for model: FeedImage) {

         view.display(FeedImageViewModel(
            location: model.location, description: model.description,
             image: nil,
             isLoading: true,
             shouldRetry: false))
     }
     
     struct InvalidImageDataError:Error{}
     func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
         
         guard let image = transformer(data) else{
             return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
         }
         
         view.display(FeedImageViewModel(
            location: model.location, description: model.description,
             image: image,
             isLoading: false,
             shouldRetry: false))
     }
     
         func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
                 view.display(FeedImageViewModel(
                    location: model.location, description: model.description,
                     image: nil,
                     isLoading: false,
                     shouldRetry: true))
             }
     
    
}
