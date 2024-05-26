//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import UIKit


extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}


