//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentailAppTests
//
//  Created by macbook abdul on 16/06/2024.
//

import XCTest
import EssentialFeed


class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primary:FeedImageDataLoader
    private class Task: FeedImageDataLoaderTask {
        func cancel() {

        }
    }
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
    }
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        primary.loadImageData(from: url, completion: {_ in})
        return Task()
    }
    
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let url = anyURL()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        _ = sut.loadImageData(from: url) { _ in }

                XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
                XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")

        
    }

    // MARK: - Helpers
    private func anyURL() -> URL {
            return URL(string: "http://a-url.com")!
        }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }

        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }

}
