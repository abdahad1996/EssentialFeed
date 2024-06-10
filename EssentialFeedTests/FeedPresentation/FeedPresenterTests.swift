//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest

class FeedPresenter {
    
    init(view:Any){
        
    }
    
}
class FeedPresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
            let view = ViewSpy()

            _ = FeedPresenter(view: view)

            XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
        }

        // MARK: - Helpers

        private class ViewSpy {
            let messages = [Any]()
        }
    
}
 



