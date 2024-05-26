//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import UIKit
import EssentialFeediOS

 extension FeedImageCell{
    func simulateRetryAction(){
        feedImageRetryButton.simulateTap()
    }
    var isShowingLocation:Bool{
        return !locationContainer.isHidden
    }
    var locationText:String?{
        return locationLabel.text
    }
    var descriptionText:String? {
        return descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator:Bool{
        return feedImageContainer.isShimmering
    }
    
    var renderedImage:Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction:Bool {
        return !feedImageRetryButton.isHidden
    }
    
}


