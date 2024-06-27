//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 09/05/2024.
//

import UIKit
import EssentialFeed


//public protocol FeedViewControllerDelegate {
//    func didRequestFeedRefresh()
//}

public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching
//public protocol CellController {
//    func view(in tableView: UITableView) -> UITableViewCell
//    func preload()
//    func cancelLoad()
//}
//
//public extension CellController {
//    func preload() {}
//    func cancelLoad() {}
//}
public final class ListViewController:UITableViewController,UITableViewDataSourcePrefetching,ResourceLoadingView,ResourceErrorView {
    
    public var onRefresh:(() -> Void)?
    private var onViewDidAppear:((ListViewController) -> Void)?
    @IBOutlet private(set) public var errorView: ErrorView?
    private var loadingControllers = [IndexPath: CellController]()
    private var tableModel = [CellController](){
        didSet {
            
            tableView.reloadData()
            
        }
    }
    
    public func display(_ cellControllers: [CellController]) {
            loadingControllers = [:]
            tableModel = cellControllers
        }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        
        if viewModel.isLoading {
            self.refreshControl?.beginRefreshing()
        }else{
            self.refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
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
    
    public override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            tableView.sizeTableHeaderToFit()
        }
    
    @IBAction func refresh() {
        onRefresh?()
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
        let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath)
//        return cellController(forRowAt: indexPath).view(in: tableView)
        
    }
    
//    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cellController = cellController(forRowAt: indexPath)
//        (cell as? FeedImageCell).map(cellController.setCell)
//        cellController.preload()
//    }
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(forRowAt: indexPath)
        controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView(tableView, prefetchRowsAt: [indexPath])
//           cellController(forRowAt: indexPath).preload()
        }
    }
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = removeLoadingController(forRowAt: indexPath)
            controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
//    func cancelTask(forRowAt indexPath:IndexPath) {
//        removeCellControllers(forRowAt: indexPath)
//    }
    
    private func removeLoadingController(forRowAt indexPath:IndexPath) -> CellController?{
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
    
    private func cellController(forRowAt indexPath:IndexPath) -> CellController{
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return  controller
    }
    
}

