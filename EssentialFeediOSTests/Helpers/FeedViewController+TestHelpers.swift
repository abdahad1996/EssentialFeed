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
    //cellforrow
    @discardableResult
    func simulateFeedImageViewVisible(at index:Int) -> FeedImageCell? {
        return feedImageView(at: index)
        
    }
    
    
    //MARK: triggers delegate method
    
    //didEndDisplaying
    @discardableResult
    func simulateFeedImageViewNotVisible(at index:Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: numberOfSections)
        delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
        return cell
    }
    
    //willDisplay
    @discardableResult
    func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewNotVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: numberOfSections)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        
        return view
    }
    
    //prefetching
    func simulateFeedImageViewNearVisible(at index:Int){
        let datasource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: numberOfSections)
        datasource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    //prefetching
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
