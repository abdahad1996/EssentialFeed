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
    private var onViewDidAppear:((FeedViewController) -> Void)?
    var tableModel = [FeedImageCellController](){
        didSet {
            self.tableView.reloadData()
        }
    }
    
     convenience init(refreshController:FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.refreshController?.refresh()
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
        tableModel[indexPath.row].cancel()
    }
    
    private func cellController(forRowAt indexPath:IndexPath) -> FeedImageCellController{
        return tableModel[indexPath.row]
    }
    
}

