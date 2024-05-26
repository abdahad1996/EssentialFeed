//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import UIKit

 class FakeRefreshControl:UIRefreshControl{
    private var _isRefreshing = false
    override var isRefreshing: Bool {
        return _isRefreshing
    }
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

 extension UIRefreshControl {
    func simulatePullToRefresh(){
        simulate(event: .valueChanged)
    }
}
