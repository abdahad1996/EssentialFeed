//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/06/2024.
//

import Foundation
import EssentialFeed
import UIKit

public class ImageCommentCellController: CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
            cell.messageLabel.text = model.message
            cell.usernameLabel.text = model.username
            cell.dateLabel.text = model.date
            return cell
    }
    
    
}
