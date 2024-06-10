//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest

struct FeedErrorViewModel {
    let message: String?
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}
protocol FeedLoadingView{
    func display(_ viewModel:FeedLoadingViewModel)
}

class FeedPresenter {
    
    let feedLoadingView:FeedLoadingView
    private let errorView: FeedErrorView
    
    
    init(feedLoadingView: FeedLoadingView, errorView:FeedErrorView) {
        self.feedLoadingView = feedLoadingView
        self.errorView = errorView
        
    }
    
    func didStartLoadingFeed(){
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(.init(message: .none))

    }
}
class FeedPresenterTests: XCTestCase {
    
    
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
    
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedLoadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy:FeedLoadingView,FeedErrorView {
        
        enum Message:Equatable {
            case feedLoading(isLoading: Bool)
            case displayError(message:String?)

            
        }
        var messages = [Message]()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.feedLoading(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel:FeedErrorViewModel) {
            messages.append(.displayError(message: viewModel.message))
        }
        
        
        
    }
    
}




