//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 07/06/2024.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import UIKit

class FeedLoaderPresentationAdapter:FeedViewControllerDelegate {
    
    var presenter:FeedPresenter?
    let loader:FeedLoader
    
    init( loader: FeedLoader) {
       
        self.loader = loader
    }
    
    func didRequestFeedRefresh(){
        presenter?.didStartLoadingFeed()
        
        loader.load {[weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
            
        }
    }
}
