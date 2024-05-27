//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 09/05/2024.
//

import UIKit
import EssentialFeed

public final class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching {
    
    
    public var refreshController:FeedRefreshViewController?
    private var imageLoader:FeedImageLoader?
    private var onViewDidAppear:((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()
    var cellControllers = [IndexPath: FeedImageCellController]()
    
    public convenience init(loader: FeedLoader,imageLoader:FeedImageLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: loader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.refreshController?.refresh()
        }
        
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
            self?.tableView.reloadData()
        }
        
    }
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewDidAppear?(self)
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return cellController(forRowAt: indexPath).view()
        
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellControllers(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
           _ = cellController(forRowAt: indexPath).view()
        }
    }
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellControllers)
    }
         
      func cancelTask(forRowAt indexPath:IndexPath) {
          removeCellControllers(forRowAt: indexPath)
        }
    
    private func removeCellControllers(forRowAt indexPath:IndexPath){
        cellControllers[indexPath] = nil
    }
    
    private func cellController(forRowAt indexPath:IndexPath) -> FeedImageCellController{
        let cellController = FeedImageCellController(model: tableModel[indexPath.row], imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
}

