//
//  SceneDelegateTests.swift
//  EssentailAppTests
//
//  Created by macbook abdul on 20/06/2024.
//

import Foundation
import XCTest
@testable import EssentailApp
import EssentialFeediOS

class SceneDelegateTests:XCTestCase{
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController as? UINavigationController
        
        let topViewController = root?.topViewController
        
        XCTAssertTrue(topViewController is FeedViewController)
        
        
    }
}
