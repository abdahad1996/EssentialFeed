//
//  EssentailAppUITests.swift
//  EssentailAppUITests
//
//  Created by macbook abdul on 20/06/2024.
//

import XCTest

final class EssentailAppUITests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
            XCTAssertEqual(feedCells.count, 22)

        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
                XCTAssertTrue(firstImage.exists)
        
        
    }
    
}
