//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/06/2024.
//

import Foundation
import XCTest
import EssentialFeediOS
import EssentialFeed

class ImageCommentsSnapshotTests:XCTestCase{
    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }
    
    
    // MARK: - Helpers

        private func makeSUT() -> ListViewController {
            let bundle = Bundle(for: ListViewController.self)
            let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
            let controller = storyboard.instantiateInitialViewController() as! ListViewController
            controller.loadViewIfNeeded()
            controller.tableView.showsVerticalScrollIndicator = false
            controller.tableView.showsHorizontalScrollIndicator = false
            return controller
        }
    private func comments() -> [CellController] {
        commentController().map { cellController in
            CellController(id: UUID(), cellController)
        }
    }

    private func commentController() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "East Side Gallery\nMemorial in Berlin, Germany",
                    date: "10 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a."
                )
            ),
        ]
    }

}
