//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import UIKit
import EssentialFeediOS

extension FeedViewController{
    
    //triggers image requests as cell is initalized
    @discardableResult
    func simulateFeedImageViewVisible(at index:Int) -> FeedImageCell? {
        return feedImageView(at: index)
        
    }
    
    //triggers delegate method
    func simulateFeedImageViewNotVisible(at index:Int) {
        let cell = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: numberOfSections)
        delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
    }
    
    func simulateFeedImageViewNearVisible(at index:Int){
        let datasource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: numberOfSections)
        datasource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at index:Int){
        simulateFeedImageViewNearVisible(at: index)
        let datasource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: numberOfSections)

        datasource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func replaceRefreshControlWithFakeForiOS17Support(){
        let fake = FakeRefreshControl()
        refreshControl?.allTargets.forEach({ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        })
        
        refreshControl = fake
        refreshController?.view = fake
    }
    
    func simulateAppearance(){
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    func numberOfRenderedFeedImageViews() -> Int {
        self.tableView.numberOfRows(inSection: numberOfSections)
    }
    
    private var numberOfSections:Int{
        return 0
    }
    
    func feedImageView(at index:Int) -> FeedImageCell? {
        let ds = tableView.dataSource
        let indexpath = IndexPath(row: index, section: numberOfSections)
        return ds?.tableView(tableView, cellForRowAt: indexpath) as? FeedImageCell
    }
}
