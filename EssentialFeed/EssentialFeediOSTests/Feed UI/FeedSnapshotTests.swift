//
//  FeedSnapshotTests.swift
//  EssentailAppTests
//
//  Created by macbook abdul on 20/06/2024.
//

import Foundation
import EssentialFeediOS
import XCTest
import EssentialFeed

class FeedSnapshotTests: XCTestCase {

//    func test_emptyFeed() {
//        let sut = makeSUT()
//
//        sut.display(emptyFeed())
//
//
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
//    }
//
//    func test_feedWithContent() {
//            let sut = makeSUT()
//
//            sut.display(feedWithContent())
//
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
//
//    }
//    
    func test_feedWithErrorMessage() {
            let sut = makeSUT()

            sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
    }
    
    func test_feedWithFailedImageLoading() {
            let sut = makeSUT()

            sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }
    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.loadViewIfNeeded()
        
        return controller
    }

    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }

    private func feedWithContent() -> [ImageStub] {
            return [
                ImageStub(
                    description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    location: "East Side Gallery\nMemorial in Berlin, Germany",
                    image: UIImage.make(withColor: .red)
                ),
                ImageStub(
                    description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                    location: "Garth Pier",
                    image: UIImage.make(withColor: .green)
                )
            ]
        }

    
    private func feedWithFailedImageLoading() -> [ImageStub] {
            return [
                ImageStub(
                    description: nil,
                    location: "Cannon Street, London",
                    image: nil
                ),
                ImageStub(
                    description: nil,
                    location: "Brighton Seafront",
                    image: nil
                )
            ]
        }
    
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
            stub.controller = cellController
            return cellController
        }

        display(cells)
    }
}
private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    weak var controller: FeedImageCellController?
    let image:UIImage?
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            location: location,
            description: description)
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
            if let image = image {
                    controller?.display(image)
                    controller?.display(ResourceErrorViewModel(message: .none))
            } else {
                    controller?.display(ResourceErrorViewModel(message: "any"))
            }
    }
    
    func didCancelImageRequest() {}
}


