//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 08/05/2024.
//

import Foundation
import XCTest
import EssentialFeed
import UIKit

class FeedViewController:UIViewController {
    private var loader:FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load{_ in }
    }
    
}

final class FeedViewControllerTests:XCTestCase{
    func test_init_doesNotCallLoad(){
        let loader = loaderSpy()
        let sut =  FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed(){
        let loader = loaderSpy()
        let sut =  FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.callCount, 1)
    }
}

class loaderSpy:FeedLoader{
    var callCount = 0
    func load(completion: @escaping (Result<[FeedImage],Error>) -> Void) {
        callCount = callCount + 1
    }
    
    
}
