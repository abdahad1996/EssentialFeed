//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = loadView()
    
    var delegate:FeedRefreshViewControllerDelegate?
    
     
    
    fileprivate func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    @objc func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    
}

extension FeedRefreshViewController:FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel) {
        
        if viewModel.isLoading {
            view.beginRefreshing()
        }else{
            view.endRefreshing()
        }
    }
    
    
}
