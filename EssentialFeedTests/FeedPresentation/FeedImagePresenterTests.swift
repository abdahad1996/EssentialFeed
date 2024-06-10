//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest

class FeedImagePresenter {
    let view:Any
    
    init(view: Any) {
        self.view = view
    }
    
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView(){
        let (_,view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
            let view = ViewSpy()
            let sut = FeedImagePresenter(view: view)
            trackForMemoryLeaks(view, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, view)
        }
    
    
    private class ViewSpy {
        let messages = [Any]()
    }
    
    
}
