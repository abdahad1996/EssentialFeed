//
//  LocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 07/06/2024.
//

import Foundation
import XCTest
@testable import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: presentationBundle, table)
    }
}

   
