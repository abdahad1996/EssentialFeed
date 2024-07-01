//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import UIKit
import EssentialFeediOS

extension ListViewController{
    
    //triggers image requests as cell is initalized
    //cellforrow
    @discardableResult
    func simulateFeedImageViewVisible(at index:Int) -> FeedImageCell? {
        return feedImageView(at: index)
        
        
    }
    
    func numberOfRows(in section: Int) -> Int {
            tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
        }

        func cell(row: Int, section: Int) -> UITableViewCell? {
            guard numberOfRows(in: section) > row else {
                return nil
            }
            let ds = tableView.dataSource
            let index = IndexPath(row: row, section: section)
            return ds?.tableView(tableView, cellForRowAt: index)
        }
    //MARK: triggers delegate method
    
    //didEndDisplaying
    @discardableResult
    func simulateFeedImageViewNotVisible(at index:Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
        return cell
    }
    
    //willDisplay
    @discardableResult
    func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewNotVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        
        return view
    }
    
    //prefetching
    func simulateFeedImageViewNearVisible(at index:Int){
        let datasource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        datasource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    //prefetching
    func simulateFeedImageViewNotNearVisible(at index:Int){
        simulateFeedImageViewNearVisible(at: index)
        let datasource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)

        datasource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
            return simulateFeedImageViewVisible(at: index)?.renderedImage
        }
    var errorMessage: String? {
        return errorView.message
    }

    func simulateTapOnFeedImage(at row: Int) {
            let delegate = tableView.delegate
            let index = IndexPath(row: row, section: feedImagesSection)
            delegate?.tableView?(tableView, didSelectRowAt: index)
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
    
//    func simulateAppearance(){
//        beginAppearanceTransition(true, animated: false)
//        endAppearanceTransition()
//    }
    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImagesSection)
    }
    
//    private var numberOfSections:Int{
//        return 0
//    }
    
    func feedImageView(at index:Int) -> FeedImageCell? {
        cell(row: index, section: feedImagesSection) as? FeedImageCell
    }
    private var feedImagesSection: Int { 0 }

}

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
}
extension ListViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
    
    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeUIRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fakeRefreshControl
    }
    
    private class FakeUIRefreshControl: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        numberOfRows(in: commentsSection)
    }

    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }

    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }

    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }

    private func commentView(at row: Int) -> ImageCommentCell? {
        cell(row: row, section: commentsSection) as? ImageCommentCell
    }

    private var commentsSection: Int {
        return 0
    }
}
