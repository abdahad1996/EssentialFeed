//
//  EssentailAppTests.swift
//  EssentailAppTests
//
//  Created by macbook abdul on 16/06/2024.
//

import XCTest
import EssentialFeed

final private class FeedLoaderWithFallbackComposite:FeedLoader {
    
    let primary:FeedLoader
    let fallback:FeedLoader

    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (Result<[EssentialFeed.FeedImage], any Error>) -> Void) {
        primary.load { [weak self ] result in
            guard self != nil else {return}
            switch result {
            case .success(let feed):
                completion(result)
            case .failure(let error):
                self?.fallback.load(completion: completion)
            }
        }
    }
}
class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)

            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
            let fallbackFeed = uniqueFeed()
            let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))

            let exp = expectation(description: "Wait for load completion")

            sut.load { result in
                switch result {
                case let .success(receivedFeed):
                    XCTAssertEqual(receivedFeed, fallbackFeed)

                case .failure:
                    XCTFail("Expected successful load feed result, got \(result) instead")
                }

                exp.fulfill()
            }

            wait(for: [exp], timeout: 1.0)
        }

 
    // MARK: - Helpers

        private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
            let primaryLoader = LoaderStub(result: primaryResult)
            let fallbackLoader = LoaderStub(result: fallbackResult)
            let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
            trackForMemoryLeaks(primaryLoader, file: file, line: line)
            trackForMemoryLeaks(fallbackLoader, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return sut
        }

        private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
            addTeardownBlock { [weak instance] in
                XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
            }
        }
    
    private func anyNSError() -> NSError {
            return NSError(domain: "any error", code: 0)
        }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)]
    }

    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result

        init(result: FeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }

}
