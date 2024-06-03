//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit


final class FeedImageCellController {
    private let viewModel:FeedImageViewModel<UIImage>
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    public func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        
        return cell
    }
    
    func binded(_ cell:FeedImageCell) -> FeedImageCell{
         
        
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        
        cell.onRetry = viewModel.loadImageData
        viewModel.onImageLoadingStateChange = {[weak cell]  isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
            
        }
        
        viewModel.onShouldRetryImageLoadStateChange = {[weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
            
        }
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        return cell
       
        
    }
    
    func preload(){
        viewModel.loadImageData()
    }
    
    func cancel(){
        viewModel.cancelImageDataLoad()
    }
}




