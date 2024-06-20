//
//  UIView+TestHelpers.swift
//  EssentailAppTests
//
//  Created by macbook abdul on 20/06/2024.
//

import Foundation
import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
