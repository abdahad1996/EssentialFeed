//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView{
    func display(_ viewModel:FeedLoadingViewModel)
}

class FeedPresenter {
    
    let feedLoadingView:FeedLoadingView
    
    init(feedLoadingView:FeedLoadingView){
        self.feedLoadingView = feedLoadingView
    }
    
    func didStartLoadingFeed(){
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}
class FeedPresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages,[.feedLoading(isLoading: true)])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedLoadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy:FeedLoadingView {
        
        enum Message:Equatable {
            case feedLoading(isLoading: Bool)

            
        }
        var messages = [Message]()
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.feedLoading(isLoading: viewModel.isLoading))
        }
    }
    
}




