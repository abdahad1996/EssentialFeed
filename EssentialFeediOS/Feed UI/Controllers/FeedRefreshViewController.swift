//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = {
        return binded(UIRefreshControl())
    }()

    let viewModel:FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    fileprivate func binded(_ view:UIRefreshControl) -> UIRefreshControl{
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            
            if isLoading {
                self?.view.beginRefreshing()
            }else{
                self?.view.endRefreshing()
            }
            
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    
}
