//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 09/05/2024.
//

import UIKit
import EssentialFeed

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching,FeedLoadingView,FeedErrorView {
    
    var delegate:FeedViewControllerDelegate?
    private var onViewDidAppear:((FeedViewController) -> Void)?
    @IBOutlet private(set) public var errorView: ErrorView?

    var tableModel = [FeedImageCellController](){
        didSet {
            
            tableView.reloadData()
            
        }
    }
    
    public func display(_ viewModel: FeedLoadingViewModel) {
        
        if viewModel.isLoading {
            self.refreshControl?.beginRefreshing()
        }else{
            self.refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: FeedErrorViewModel) {
        if let message = viewModel.message {
            errorView?.show(message: message)
        } else {
            errorView?.hideMessage()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.refresh()
        }
        
    }
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
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
        return cellController(forRowAt: indexPath).view(in: tableView)
        
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellController = cellController(forRowAt: indexPath)
        (cell as? FeedImageCell).map(cellController.setCell)
        cellController.preload()
    }
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellControllers(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            _ = cellController(forRowAt: indexPath).view(in: tableView)
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

