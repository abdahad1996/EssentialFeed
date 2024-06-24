////
////  FeedLoaderCacheDecorator.swift
////  EssentailAppTests
////
////  Created by macbook abdul on 17/06/2024.
////
//
//import Foundation
//import XCTest
//import EssentialFeed
//import EssentailApp
//
//class FeedLoaderCacheDecoratorTests:XCTestCase,FeedLoaderTestCase{
//    
//    func test_load_deliversFeedOnLoadSuccess(){
//        let feed = uniqueFeed()
//        let sut = makeSUT(loaderResult: .success(feed))
//        expect(sut, toCompleteWith: .success(feed))
//    }
//    
//    func test_load_deliversErrorOnLoadFailure(){
//        let sut = makeSUT(loaderResult: .failure(anyNSError()))
//        expect(sut, toCompleteWith: .failure(anyNSError()))
//        
//    }
//    
//    func test_load_cachesLoadedFeedOnLoaderSuccess() {
//        let cache = CacheSpy()
//        let feed = uniqueFeed()
//        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
//        
//        sut.load { _ in }
//        
//        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
//        
//    }
//    
//    func test_load_doesNotCacheOnLoaderFailure() {
//        let cache = CacheSpy()
//        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
//        
//        sut.load { _ in }
//        
//        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache feed on load error")
//    }
//    
//    // MARK: - Helpers
//    
//    private func makeSUT(loaderResult: FeedLoader.Result,cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
//        let loader = FeedLoaderStub(result: loaderResult)
//        let sut = FeedLoaderCacheDecorator(loader: loader,cache:cache)
//        trackForMemoryLeaks(loader, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return sut
//    }
//    
//    private func uniqueFeed() -> [FeedImage] {
//        return [FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)]
//    }
//    
//    
//    private class CacheSpy: FeedCache {
//        private(set) var messages = [Message]()
//        
//        enum Message: Equatable {
//            case save([FeedImage])
//        }
//        
//        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
//            messages.append(.save(feed))
//            completion(.success(()))
//        }
//    }
//    
//    
//}
