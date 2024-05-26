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


public class FeedViewController:UITableViewController {
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
        tasks[indexPath] = imageLoader?.loadImageData(from: tableModel[indexPath.row].url, completion: { [weak cell]  result in
            cell?.feedImageContainer.stopShimmering()
            let data = try? result.get()
            cell?.feedImageView.image = data.map(UIImage.init) ?? nil
        })
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}


public class FeedImageCell:UITableViewCell{
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    
    

}
