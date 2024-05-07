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
      
        let (sut,loader) =  makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed(){
         
        let (sut,loader) =  makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.callCount, 1)
    }
    
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> (FeedViewController,loaderSpy) {
        let loader = loaderSpy()
        let sut =  FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut,loader)
    }
}

class loaderSpy:FeedLoader{
    var callCount = 0
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        callCount = callCount + 1
    }
    
    
}
