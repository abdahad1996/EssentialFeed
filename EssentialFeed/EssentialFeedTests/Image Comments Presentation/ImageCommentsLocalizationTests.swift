//
//  LocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 07/06/2024.
//

import Foundation
import XCTest
@testable import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: presentationBundle, table)
    }
}

   
