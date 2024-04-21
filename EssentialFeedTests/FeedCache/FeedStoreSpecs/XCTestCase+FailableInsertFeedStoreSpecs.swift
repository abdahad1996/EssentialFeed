//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 21/04/2024.
//

import Foundation
import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImages().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImages().local, Date()), to: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
}
