//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import UIKit


extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}


