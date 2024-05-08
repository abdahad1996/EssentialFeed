//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 08/05/2024.
//

import Foundation
import XCTest
import EssentialFeed
import UIKit

class FeedViewController:UITableViewController {
    private var loader:FeedLoader?
    private var onViewDidAppear:((FeedViewController) -> Void)?
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.refreshControl?.beginRefreshing()
            vc.load()
        }
        
        
    }
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewDidAppear?(self)
    }
    
    @objc func load(){
        loader?.load{_ in }
    }
}


final class FeedViewControllerTests:XCTestCase{
    func test_init_doesNotCallLoad(){
      
        let (sut,loader) =  makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed(){
         
        let (sut,loader) =  makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.callCount, 1)
    }
    
    func test_viewDidLoad_showsLoadingIndicator(){
         
        let (sut,loader) =  makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()

        sut.simulateAppearance()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    
    func test_pullsToRefresh_loadsFeed(){
         
        let (sut,loader) =  makeSUT()
 
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()

        sut.simulateAppearance()

        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.callCount, 2)
    }
    
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> (FeedViewController,loaderSpy) {
        let loader = loaderSpy()
        let sut =  FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut,loader)
    }
}

class loaderSpy:FeedLoader{
    var callCount = 0
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        callCount = callCount + 1
    }
    
    
}
private extension FeedViewController{
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
}


private extension UIRefreshControl {
    func simulatePullToRefresh(){
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}

private class FakeRefreshControl:UIRefreshControl{
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
