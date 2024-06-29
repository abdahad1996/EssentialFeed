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
import EssentailApp


class CommentsUIIntegrationTests:FeedUIIntegrationTests{
    
     func test_commentsView_hasTitle() {
        let (sut,loader) =  makeSUT()
        
        sut.simulateAppearance()

        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    
    override func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1], at: 1)
        assertThat(sut, isRendering: [image0, image1])
    }
    
    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
        
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let image0 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    // MARK: - Image View Tests
    override func test_feedImageView_loadsImageURLWhenVisible() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with:[image0,image1])
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
        
        
    }
    override func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with:[image0,image1])
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
        
    }
    
    override func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
       
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with:[image0,image1])
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
    
    override func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
        sut.simulateAppearance()

        loader.completeFeedLoading(with:[image0,image1])
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 2)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    override func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut,loader) =  makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "a description", location: "a location")
        
        sut.simulateAppearance()

        
        loader.completeFeedLoading(with:[image0,image1])
        
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
        
        
    }
    
    override func test_feedImageViewRetryAction_retriesImageLoad() {
        
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()

        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
        
    }
    
    override func test_feedImageView_preloadsImageURLWhenNearVisible() {
        
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()

        
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
        
    }
    
    override func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
            let image0 = makeImage(url: URL(string: "http://url-0.com")!)
            let image1 = makeImage(url: URL(string: "http://url-1.com")!)
            let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        
            loader.completeFeedLoading(with: [image0, image1])
            XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")

            sut.simulateFeedImageViewNotNearVisible(at: 0)
            XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")

            sut.simulateFeedImageViewNotNearVisible(at: 1)
            XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
        }
    
    override func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        
        let image0 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

    
        loader.completeFeedLoading(with: [image0])
        
        let cell:FeedImageCell? = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData(), at: 0)

        XCTAssertNil(cell?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
        
    }
    override func test_feedImageView_reloadsImageURLWhenBecomingVisibleAgain() {
            let image0 = makeImage(url: URL(string: "http://url-0.com")!)
            let image1 = makeImage(url: URL(string: "http://url-1.com")!)
            let (sut, loader) = makeSUT()

            sut.simulateAppearance()
            loader.completeFeedLoading(with: [image0, image1])

            sut.simulateFeedImageBecomingVisibleAgain(at: 0)

            XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url], "Expected two image URL request after first view becomes visible again")

            sut.simulateFeedImageBecomingVisibleAgain(at: 1)

            XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url, image1.url, image1.url], "Expected two new image URL request after second view becomes visible again")
        }

    override func test_feedImageView_configuresViewCorrectlyWhenCellBecomingVisibleAgain() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view0 = sut.simulateFeedImageBecomingVisibleAgain(at: 0)
        
        XCTAssertEqual(view0?.renderedImage, nil, "Expected no rendered image when view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action when view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator when view becomes visible again")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 1)
        
        XCTAssertEqual(view0?.renderedImage, imageData, "Expected rendered image when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator when image loads successfully after view becomes visible again")
    }
    override func test_feedImageView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
        let image0 = makeImage(url: URL(string: "http://url-1.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)

        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        
            loader.completeFeedLoading(with: [image0, image1])

            let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
            view0.prepareForReuse()

            let imageData0 = UIImage.make(withColor: .red).pngData()!
            loader.completeImageLoading(with: imageData0, at: 0)

            XCTAssertEqual(view0.renderedImage, .none, "Expected no image state change for reused view once image loading completes successfully")
        }
    
    override func test_feedImageView_showsDataForNewViewRequestAfterPreviousViewIsReused() throws {
            let (sut, loader) = makeSUT()

            sut.simulateAppearance()
            loader.completeFeedLoading(with: [makeImage(), makeImage()])

            let previousView = try XCTUnwrap(sut.simulateFeedImageViewNotVisible(at: 0))

            let newView = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
            previousView.prepareForReuse()

            let imageData = UIImage.make(withColor: .red).pngData()!
            loader.completeImageLoading(with: imageData, at: 1)

            XCTAssertEqual(newView.renderedImage, imageData)
        }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }

        wait(for: [exp],timeout: 1)
        
        
    }
    
//    func test_feedImageView_recapturesCellOnWillDisplayCell() {
//        let image0 = makeImage(url: URL(string: "http://url-1.com")!)
//        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
//
//        let (sut, loader) = makeSUT()
//
//        sut.simulateAppearance()
//
//        
//            loader.completeFeedLoading(with: [image0, image1])
//
//            // simulate that the cell is off screen for a short time
//            let cell = sut.simulateFeedImageBecomingVisibleAgain(at: 0)
//
//            let imageData0 = UIImage.make(withColor: .red).pngData()!
//            loader.completeImageLoading(with: imageData0, at: 0)
//
//
//            XCTAssertEqual(cell?.renderedImage, imageData0)
//        }
    
    
    override func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let image0 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

            loader.completeFeedLoading(with: [image0])
            _ = sut.simulateFeedImageViewVisible(at: 0)

            let exp = expectation(description: "Wait for background queue")
            DispatchQueue.global().async {
                loader.completeImageLoading(with: self.anyImageData(), at: 0)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
    
  

    
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> (ListViewController,loaderSpy) {
        let loader = loaderSpy()
        let sut =  CommentsUIComposer.commentsComposedWith(feedLoader: loader.loadPublisher, imageLoader: loader.loadImageDataPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut,loader)
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
            let image0 = makeImage()
            let image1 = makeImage()
            let (sut, loader) = makeSUT()

            sut.simulateAppearance()
            loader.completeFeedLoading(with: [image0, image1], at: 0)
            assertThat(sut, isRendering: [image0, image1])

            sut.simulateUserInitiatedFeedReload()
            loader.completeFeedLoading(with: [], at: 1)
            assertThat(sut, isRendering: [])
        }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, imageURL: url)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
}

