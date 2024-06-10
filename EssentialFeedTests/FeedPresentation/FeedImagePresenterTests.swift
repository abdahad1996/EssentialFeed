//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

struct FeedImageViewModel{
    let location:String?
    let description:String?
    let image:Any?
    let isLoading:Bool
    let shouldRetry:Bool
    
    var hasLocation: Bool {
        return location != nil
    }
    
}


protocol FeedImageView {
    func display(_ viewModel:FeedImageViewModel)

}
class FeedImagePresenter {
    private let view:FeedImageView
    private let transformer:(Data) -> Any?

    
    init(view: FeedImageView, transformer: @escaping (Data) -> Any?) {
        self.view = view
        self.transformer = transformer
    }
     
    
    func didStartLoadingImageData(for model: FeedImage) {
         view.display(FeedImageViewModel(
            location: model.location, description: model.description,
             image: nil,
             isLoading: true,
             shouldRetry: false))
     }

    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        
        view.display(FeedImageViewModel(
           location: model.location, description: model.description,
            image: transformer(data),
            isLoading: false,
            shouldRetry: true))
    }
    
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView(){
        let (_,view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage(){
        let (sut,view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        
        let message = view.messages.first
                XCTAssertEqual(view.messages.count, 1)
                XCTAssertEqual(message?.description, image.description)
                XCTAssertEqual(message?.location, image.location)
                XCTAssertEqual(message?.isLoading, true)
                XCTAssertEqual(message?.shouldRetry, false)
                XCTAssertNil(message?.image)

    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation(){
        let (sut,view) = makeSUT()
        let image = uniqueImage()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
                XCTAssertEqual(view.messages.count, 1)
                XCTAssertEqual(message?.description, image.description)
                XCTAssertEqual(message?.location, image.location)
                XCTAssertEqual(message?.isLoading, false)
                XCTAssertEqual(message?.shouldRetry, true)
                XCTAssertNil(message?.image)
        

    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
            let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, transformer: Fail)
            trackForMemoryLeaks(view, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, view)
        }
    
    private var Fail:(Data) -> Any? {
        return {_ in nil}
    }
    private class ViewSpy:FeedImageView {
        
        var messages = [FeedImageViewModel]()
        
        func display(_ viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
        
    }
    
    
}
