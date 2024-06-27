//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/06/2024.
//

import Foundation
import EssentialFeed
import UIKit

public class ImageCommentCellController:NSObject,UITableViewDataSource {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell: ImageCommentCell = tableView.dequeueReusableCell()
            cell.messageLabel.text = model.message
            cell.usernameLabel.text = model.username
            cell.dateLabel.text = model.date
            return cell
    }
    
    
}
