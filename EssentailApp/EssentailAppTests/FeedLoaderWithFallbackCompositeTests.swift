//
//  EssentailAppTests.swift
//  EssentailAppTests
//
//  Created by macbook abdul on 16/06/2024.
//

import XCTest
import EssentialFeed
import EssentailApp

//class FeedLoaderWithFallbackCompositeTests: XCTestCase,FeedLoaderTestCase {
//
//    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
//        let primaryFeed = uniqueFeed()
//        let fallbackFeed = uniqueFeed()
//        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
//
//        expect(sut, toCompleteWith: .success(primaryFeed))
//    }
//    
//    
//    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
//            let fallbackFeed = uniqueFeed()
//            let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
//
//            expect(sut, toCompleteWith:.success(fallbackFeed))
//        }
//
// 
//    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
//        
//        
//        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult:  .failure(anyNSError()))
//
//        expect(sut, toCompleteWith:.failure(anyNSError()))
//        
//    }
//    
//    // MARK: - Helpers
//    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
//        let primaryLoader = FeedLoaderStub(result: primaryResult)
//        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
//        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
//        trackForMemoryLeaks(primaryLoader, file: file, line: line)
//        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return sut
//    }
//
// 
//    private func uniqueFeed() -> [FeedImage] {
//        return [FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)]
//    }
//
//    
//
//}
