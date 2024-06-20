//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView(){
        let (sut, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage(){
        let (sut, view) = makeSUT()
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
        let (sut,view) = makeSUT(imageTransformer: Fail)
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
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        
         let image = uniqueImage()
        let data = Data()
        let transformedData = AnyImage()
        let (sut,view) = makeSUT { _ in
            transformedData
        }

        
        sut.didFinishLoadingImageData(with: data, for: image)

                let message = view.messages.first
                XCTAssertEqual(view.messages.count, 1)
                XCTAssertEqual(message?.description, image.description)
                XCTAssertEqual(message?.location, image.location)
                XCTAssertEqual(message?.isLoading, false)
                XCTAssertEqual(message?.shouldRetry, false)
                XCTAssertEqual(message?.image, transformedData)
        
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
            let image = uniqueImage()
            let (sut, view) = makeSUT()

        sut.didFinishLoadingImageData(with: anyNSError(), for: image)

            let message = view.messages.first
            XCTAssertEqual(view.messages.count, 1)
            XCTAssertEqual(message?.description, image.description)
            XCTAssertEqual(message?.location, image.location)
            XCTAssertEqual(message?.isLoading, false)
            XCTAssertEqual(message?.shouldRetry, true)
            XCTAssertNil(message?.image)
        }
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy,AnyImage>, view: ViewSpy) {
            let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
            trackForMemoryLeaks(view, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, view)
        }
    
    private var Fail:(Data) -> AnyImage? {
        return {_ in nil}
    }
    
    private struct AnyImage:Equatable{}
    private class ViewSpy:FeedImageView {
        
        var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
        
    }
    
    
}
