//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 26/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
            XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
        }
    
//    func test_map_createsViewModel() {
//        let feed = uniqueImages().models
//
//        let viewModel = ImageCommentPresenter.map(feed)
//        
//        XCTAssertEqual(viewModel.feed, feed)
//        
//        
//    }
    

    
    // MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table:String =  "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    

}




