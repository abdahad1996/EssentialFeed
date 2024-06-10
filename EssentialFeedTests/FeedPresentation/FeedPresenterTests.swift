//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
struct FeedLoadingViewModel {
    let isLoading: Bool
}
struct FeedViewModel {
    let feed: [FeedImage]
}
protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}
protocol FeedLoadingView{
    func display(_ viewModel:FeedLoadingViewModel)
}
protocol FeedView{
    func display(_ viewModel:FeedViewModel)
}
final class FeedPresenter {
    
    private let feedLoadingView:FeedLoadingView
    private let errorView: FeedErrorView
    private let feedView:FeedView
    
    static var title: String {
       return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(
                for:FeedPresenter.self
            ) ,
            comment: "Title for the feed view"
        )
        
    }
     static var feedLoadError = NSLocalizedString(
        "FEED_VIEW_CONNECTION_ERROR",
        tableName: "Feed",
        bundle: Bundle(
            for:FeedPresenter.self
        ) ,
        comment: "Error message displayed when image feed fail to load from the server"
    )
    
    init(feedLoadingView: FeedLoadingView, errorView: FeedErrorView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.errorView = errorView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed(){
        errorView.display(.noError)
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed :[FeedImage]){
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: FeedPresenter.feedLoadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
            XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
        }
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    
    func test_didStartLoadingFeed_startsLoadingAndDisplaysNoError() {
        
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()
        
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

        sut.didFinishLoadingFeed(with: anyError())
        
        XCTAssertEqual(view.messages,[.feedLoading(isLoading: false),.displayError(message: localized("FEED_VIEW_CONNECTION_ERROR"))])

    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedLoadingView: view, errorView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
   private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
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




