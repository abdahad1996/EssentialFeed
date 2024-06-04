//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = loadView()
    
    let onLoad:() -> Void
    
    init(_ onLoad: @escaping () -> Void) {
        self.onLoad = onLoad
    }
    
    fileprivate func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    @objc func refresh() {
        onLoad()
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
