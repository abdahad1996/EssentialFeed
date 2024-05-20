//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 08/05/2024.
//

import Foundation
import XCTest
import EssentialFeediOS
import EssentialFeed
import UIKit


final class FeedViewControllerTests:XCTestCase{
    
    func test_loadFeedActions_requestFeedFromLoader(){
        let (sut,loader) =  makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedFeedReload()

        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        
        sut.simulateUserInitiatedFeedReload()

        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut,loader) =  makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")


        loader.completion(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
 
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completion(at:1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
        
    }
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed(){
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
                let image1 = makeImage(description: nil, location: "another location")
                let image2 = makeImage(description: "another description", location: nil)
                let image3 = makeImage(description: nil, location: nil)

        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        
        loader.completion(with:[image0])
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(),1)

        let view = sut.feedImageView(at: 0) as? FeedImageCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, true)
        XCTAssertEqual(view?.descriptionText, image0.description)
        XCTAssertEqual(view?.locationText, image0.location)
        
        
        sut.simulateUserInitiatedFeedReload()
        loader.completion(with:[image0,image1,image2,image3])
        assertThat(sut,isRendering:[image0,image1,image2,image3])

    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
            guard sut.numberOfRenderedFeedImageViews() == feed.count else {
                return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
            }

            feed.enumerated().forEach { index, image in
                assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
            }
        }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
            let view = sut.feedImageView(at: index)

            guard let cell = view as? FeedImageCell else {
                return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            }

            let shouldLocationBeVisible = (image.location != nil)
            XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)

            XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)

            XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
        }
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, imageURL: url)
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
    var completions = [(FeedLoader.Result) -> Void]()
    
    var loadCallCount :Int {
        return completions.count
    }
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completions.append(completion)
    }
    
    func completion(with feed:[FeedImage] = [],at index:Int = 0){
        completions[index](.success(feed))
    }
    
    
}
private extension FeedViewController{
    
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
    
    func feedImageView(at index:Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexpath = IndexPath(row: index, section: numberOfSections)
        return ds?.tableView(tableView, cellForRowAt: indexpath)
    }
}

private extension FeedImageCell{
    var isShowingLocation:Bool{
        return !locationContainer.isHidden
    }
    var locationText:String?{
        return locationLabel.text
    }
    var descriptionText:String? {
        return descriptionLabel.text
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
