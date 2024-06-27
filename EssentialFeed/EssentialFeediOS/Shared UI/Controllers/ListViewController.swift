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

public struct CellController {
    let dataSource:UITableViewDataSource
    let delegate:UITableViewDelegate?
    let dataSourcePrefetching:UITableViewDataSourcePrefetching?
    
    public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
            self.dataSource = dataSource
            self.delegate = dataSource
            self.dataSourcePrefetching = dataSource
        }

        public init(_ dataSource: UITableViewDataSource) {
            self.dataSource = dataSource
            self.delegate = nil
            self.dataSourcePrefetching = nil
        }

}
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
    private(set) public var errorView = ErrorView()
    private var loadingControllers = [IndexPath: CellController]()
    private var tableModel = [CellController](){
        didSet {
            tableView.reloadData()
        }
    }
    
    private func configureErrorView() {
            let container = UIView()
            container.backgroundColor = .clear
            container.addSubview(errorView)

            errorView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
                errorView.topAnchor.constraint(equalTo: container.topAnchor),
                container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
            ])

            tableView.tableHeaderView = container

            errorView.onHide = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.sizeTableHeaderToFit()
                self?.tableView.endUpdates()
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
        errorView.message = viewModel.message
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        configureErrorView()
        
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
        let ds = cellController(forRowAt: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
//        return cellController(forRowAt: indexPath).view(in: tableView)
        
    }
    
//    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cellController = cellController(forRowAt: indexPath)
//        (cell as? FeedImageCell).map(cellController.setCell)
//        cellController.preload()
//    }
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = removeLoadingController(forRowAt: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dataSourcePrefetching = cellController(forRowAt: indexPath).dataSourcePrefetching
            dataSourcePrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
//           cellController(forRowAt: indexPath).preload()
        }
    }
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dataSourcePrefetching = removeLoadingController(forRowAt: indexPath)?.dataSourcePrefetching
            dataSourcePrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
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

