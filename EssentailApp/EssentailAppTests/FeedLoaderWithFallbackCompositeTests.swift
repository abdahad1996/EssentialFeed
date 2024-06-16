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
        primary.load(completion: completion)
    }
}
class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

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
