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

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
public struct CellController {
    
    
    let id:AnyHashable
    let dataSource:UITableViewDataSource
    let delegate:UITableViewDelegate?
    let dataSourcePrefetching:UITableViewDataSourcePrefetching?
    
//    public init(id:AnyHashable,_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
//            self.id = id
//            self.dataSource = dataSource
//            self.delegate = dataSource
//            self.dataSourcePrefetching = dataSource
//        }

        public init(id:AnyHashable,_ dataSource: UITableViewDataSource) {
            self.id = id
            self.dataSource = dataSource
            self.delegate = dataSource as? UITableViewDelegate
            self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
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
//    private var loadingControllers = [IndexPath: CellController]()
//    private var tableModel = [CellController](){
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
            .init(tableView: tableView) { (tableView, index, controller) in
                print(index)
                return controller.dataSource.tableView(tableView, cellForRowAt: index)
            }
        }()
    
//    private func configureErrorView() {
//            let container = UIView()
//            container.backgroundColor = .clear
//            container.addSubview(errorView)
//
//            errorView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//                container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
//                errorView.topAnchor.constraint(equalTo: container.topAnchor),
//                container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
//            ])
//
//            tableView.tableHeaderView = container
//
//            errorView.onHide = { [weak self] in
//                self?.tableView.beginUpdates()
//                self?.tableView.sizeTableHeaderToFit()
//                self?.tableView.endUpdates()
//            }
//        }
    
    public func display(_ cellControllers: [CellController]) {
//            loadingControllers = [:]
//            tableModel = cellControllers
        
        var snapshot = NSDiffableDataSourceSnapshot<Int,CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers,toSection: 0)
        if #available(iOS 15.0, *) {
                    dataSource.applySnapshotUsingReloadData(snapshot)
                } else {
                    dataSource.apply(snapshot)
                }
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
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
         tableView.dataSource = dataSource
        tableView.tableHeaderView = errorView.makeContainer()

        
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
       
        configureTableView()
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
    
//    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tableModel.count
//    }
//    
//    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let ds = cellController(forRowAt: indexPath).dataSource
//        return ds.tableView(tableView, cellForRowAt: indexPath)
////        return cellController(forRowAt: indexPath).view(in: tableView)
//        
//    }
    
//    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cellController = cellController(forRowAt: indexPath)
//        (cell as? FeedImageCell).map(cellController.setCell)
//        cellController.preload()
//    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = cellController(at:  indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dataSourcePrefetching = cellController(at: indexPath)?.dataSourcePrefetching
            dataSourcePrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
//           cellController(forRowAt: indexPath).preload()
        }
    }
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dataSourcePrefetching = cellController(at: indexPath)?.dataSourcePrefetching
            dataSourcePrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    
    
//    func cancelTask(forRowAt indexPath:IndexPath) {
//        removeCellControllers(forRowAt: indexPath)
//    }
    
//    private func removeLoadingController(forRowAt indexPath:IndexPath) -> CellController?{
//        let controller = loadingControllers[indexPath]
//        loadingControllers[indexPath] = nil
//        return controller
//    }
    
    private func cellController(at indexPath:IndexPath) -> CellController?{
//        let controller = tableModel[indexPath.row]
//        loadingControllers[indexPath] = controller
         
        return  dataSource.itemIdentifier(for: indexPath)
    }
    
}

