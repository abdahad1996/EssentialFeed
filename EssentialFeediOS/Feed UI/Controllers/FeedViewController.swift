//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 09/05/2024.
//

import UIKit
import EssentialFeed


public final class FeedRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onRefresh: (([FeedImage]) -> Void)?

    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}


public final class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching {
    
    
    public var refreshController:FeedRefreshViewController?
    private var imageLoader:FeedImageLoader?
    private var onViewDidAppear:((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath:FeedImageDataLoaderTask]()
    
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
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedImageCell()
        
        cell.locationContainer.isHidden = (tableModel[indexPath.row].location == nil)
        cell.locationLabel.text = tableModel[indexPath.row].location
        cell.descriptionLabel.text = tableModel[indexPath.row].description
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        cell.feedImageRetryButton.isHidden = true
        
        let loadImage = { [weak self,weak cell ] in
            guard let self = self else{return}
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: tableModel[indexPath.row].url, completion: { [weak cell]  result in
                cell?.feedImageContainer.stopShimmering()
                let data = try? result.get()
                cell?.feedImageView.image = data.map(UIImage.init) ?? nil
                cell?.feedImageRetryButton.isHidden = (data != nil)
            })
        }
       
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: tableModel[indexPath.row].url, completion: {_ in})
        }
    }
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
         
      func cancelTask(forRowAt indexPath:IndexPath) {
            self.tasks[indexPath]?.cancel()
            self.tasks[indexPath] = nil
        }
    
}

