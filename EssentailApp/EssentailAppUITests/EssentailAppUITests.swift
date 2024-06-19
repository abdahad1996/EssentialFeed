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
        
        XCTAssertEqual(app.cells.count, 22)
        
        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
        
    }
    
}
