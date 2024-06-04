//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = loadView()
    
    let presenter:FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    fileprivate func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    @objc func refresh() {
        presenter.loadFeed()
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
