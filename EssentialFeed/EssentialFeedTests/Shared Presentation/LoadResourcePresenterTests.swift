//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest
import EssentialFeed


class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    
    func test_didStartLoadingFeed_startsLoadingAndDisplaysNoError() {
        
        let (sut, view) = makeSUT()

        sut.didStartLoading()
        
        XCTAssertEqual(
            view.messages,
            
            [.feedLoading(
                isLoading: true
            ),
             .displayError(message:.none)
            ]
        )
        
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImages().models

        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages,[.displayFeed(feed: feed),.feedLoading(isLoading: false)])
        
    }
    
    func test_didFinishLoadingFeed_stopsLoadingAndDisplaysError(){
        let (sut, view) = makeSUT()

        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages,[.feedLoading(isLoading: false),.displayError(message: localized("FEED_VIEW_CONNECTION_ERROR"))])

    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LoadResourcePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter(feedLoadingView: view, errorView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
   private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy:FeedLoadingView,FeedErrorView,FeedView {
        
        enum Message:Hashable {
            case feedLoading(isLoading: Bool)
            case displayError(message:String?)
            case displayFeed(feed:[FeedImage])
            
        }
        var messages = Set<Message>()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.feedLoading(isLoading: viewModel.isLoading))
        }
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.displayFeed(feed: viewModel.feed))
        }
        
        func display(_ viewModel:FeedErrorViewModel) {
            messages.insert(.displayError(message: viewModel.message))
        }
        
    }
    
}




