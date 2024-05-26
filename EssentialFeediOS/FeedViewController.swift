//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 09/05/2024.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}
public protocol FeedImageLoader {
    typealias Result = Swift.Result<Data,Error>
    func loadImageData(from url: URL,completion:@escaping(Result) -> Void) -> FeedImageDataLoaderTask
}


public class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching {
    
    
    private var loader:FeedLoader?
    private var imageLoader:FeedImageLoader?
    private var onViewDidAppear:((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath:FeedImageDataLoaderTask]()
    
    public convenience init(loader: FeedLoader,imageLoader:FeedImageLoader) {
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.load()
        }
        
        
    }
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewDidAppear?(self)
    }
    
    @objc func load(){
        refreshControl?.beginRefreshing()
        loader?.load(completion: { [weak self] result in
            
            if let images = try? result.get()  {
                self?.tableModel = images
                
                self?.tableView.reloadData()
            }
            
            self?.refreshControl?.endRefreshing()
        })
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


public class FeedImageCell:UITableViewCell{
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    
}
