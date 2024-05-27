//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private let model:FeedImage
    private var task:FeedImageDataLoaderTask?
    private let imageLoader: FeedImageLoader

    init(model: FeedImage, imageLoader: FeedImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    public func view() -> UITableViewCell {
        let cell = FeedImageCell()
        
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        cell.feedImageRetryButton.isHidden = true
        
        let loadImage = { [weak self,weak cell ] in
            guard let self = self else{return}
            
            task = imageLoader.loadImageData(from: model.url, completion: { [weak cell]  result in
                cell?.feedImageContainer.stopShimmering()
                let data = try? result.get()
                cell?.feedImageView.image = data.map(UIImage.init) ?? nil
                cell?.feedImageRetryButton.isHidden = (data != nil)
            })
        }
       
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    deinit{
        task?.cancel()
    }
    
    func preload(){
        task = imageLoader.loadImageData(from: model.url, completion:{_ in})
    }
}
