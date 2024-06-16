//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
    
}
final class FeedImageCellController:FeedImageView {
    
    let delegate:FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        
        let cell:FeedImageCell = tableView.dequeueReusableCell()
        self.cell = cell
        delegate.didRequestImage()
        
        return cell
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>){
        
            cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImageAnimated(viewModel.image)
        
        cell?.onRetry = { [weak self] in
                    self?.delegate.didRequestImage()
                }
        
        cell?.onReuse = { [weak self] in
                    self?.releaseCellForReuse()
                }
        
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        
        
        cell?.feedImageView.image = viewModel.image
        
    }
    
    func preload(){
        delegate.didRequestImage()
    }
    
    func cancel(){
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
    func setCell(_ cell: FeedImageCell) {
            self.cell = cell
        }
    
}




