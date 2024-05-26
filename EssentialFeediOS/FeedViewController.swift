//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 09/05/2024.
//

import UIKit
import EssentialFeed

public class FeedViewController:UITableViewController {
    private var loader:FeedLoader?
    private var onViewDidAppear:((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
       
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
        
        return cell
    }
    
}


public class FeedImageCell:UITableViewCell{
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()

}
