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
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut,loader) =  makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        
        loader.completionWithSuccess(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completionWithSuccess(at:1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completionLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
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
        
        loader.completionWithSuccess(with:[image0])
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(),1)
        
        let view = sut.feedImageView(at: 0) as? FeedImageCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, true)
        XCTAssertEqual(view?.descriptionText, image0.description)
        XCTAssertEqual(view?.locationText, image0.location)
        
        
        sut.simulateUserInitiatedFeedReload()
        loader.completionWithSuccess(with:[image0,image1,image2,image3])
        assertThat(sut,isRendering:[image0,image1,image2,image3])
        
    }
    
    func test_LoadCompletion_doesNotAlterCurrentRenderingStateOnError(){
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completionWithSuccess(with:[image0])
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completionLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
        
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        
        loader.completionWithSuccess(with:[image0,image1])
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
        
        
    }
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        
        loader.completionWithSuccess(with:[image0,image1])
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
        
        
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        sut.simulateAppearance()
        
        loader.completionWithSuccess(with:[image0,image1])
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2)
        
        
        let cell0 = sut.simulateFeedImageViewVisible(at: 0)
        let cell1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(cell0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(cell1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(cell0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(cell1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(cell0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(cell1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
        
        
        
        
        
        
    }
    
    //MARK: HELPERS
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
        let sut =  FeedViewController(loader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut,loader)
    }
}

//MARK: SPY
class loaderSpy:FeedLoader,FeedImageLoader{
    
    
    // MARK: - FeedLoader
    private var feedRequests = [(FeedLoader.Result) -> Void]()
    
    var loadFeedCallCount :Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completionWithSuccess(with feed:[FeedImage] = [],at index:Int = 0){
        feedRequests[index](.success(feed))
    }
    
    func completionLoadingWithError(at index:Int = 0){
        let error = NSError(domain: "an error", code: 2)
        feedRequests[index](.failure(error))
    }
    
    // MARK: - FeedImageDataLoader
    
    private var imageRequests = [(url:URL,completion:(FeedImageLoader.Result) -> Void )]()
    
    var loadedImageURLs:[URL]{
        return imageRequests.map{$0.url}
    }
    private(set) var cancelledImageURLs = [URL]()
    
    
    private struct TaskSpy:FeedImageDataLoaderTask{
        public let cancelTask:() -> Void
        func cancel() {
            cancelTask()
        }
        
    }
    
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        
        imageRequests.append((url,completion))
        
        return TaskSpy { [weak self ] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    func completeImageLoading(with imageData:Data = Data(),at index:Int) {
        imageRequests[index].completion(.success(imageData))
    }
    func completeImageLoadingWithError(at index:Int) {
        let error = NSError(domain: "any", code: 0)
        imageRequests[index].completion(.failure(error))
    }
    
}

//MARK: CONTROLLER EXTENSIONS
private extension FeedViewController{
    
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
    
    var isShowingImageLoadingIndicator:Bool{
        return feedImageContainer.isShimmering
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

