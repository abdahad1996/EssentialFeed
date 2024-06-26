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
             .display(errorMessage:.none)
            ]
        )
        
    }
    
    func test_didFinishLoadingFeed_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT { resource in
            return "resource view model"
        }
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(view.messages,[.display(resource: "resource view model"),.feedLoading(isLoading: false)])
        
    }
    
    func test_didFinishLoadingFeed_stopsLoadingAndDisplaysError(){
        let (sut, view) = makeSUT()

        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages,[.feedLoading(isLoading: false),.display(errorMessage: localized("GENERIC_CONNECTION_ERROR"))])

    }

    
    // MARK: - Helpers
    private typealias SUT = LoadResourcePresenter<String,ViewSpy>
    private func makeSUT(mapper:@escaping SUT.Mapper = {_ in "Any"},file: StaticString = #file, line: UInt = #line) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(loadingView: view, errorView: view, resourceView: view,mapper:mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
   private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
       let table = "Shared"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy:ResourceView,FeedErrorView,FeedLoadingView{
        typealias ResourceViewModel = String
        enum Message:Hashable {
            case feedLoading(isLoading: Bool)
            case display(errorMessage:String?)
            case display(resource:ResourceViewModel)
            
        }
        var messages = Set<Message>()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.feedLoading(isLoading: viewModel.isLoading))
        }
        func display(_ viewModel: String) {
            messages.insert(.display(resource: viewModel))
        }
        
        func display(_ viewModel:FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
    }
    
}




