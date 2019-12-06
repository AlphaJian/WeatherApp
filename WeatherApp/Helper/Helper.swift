//
//  Helper.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit

extension String {
    var isNumberic: Bool {
          return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    var isAlphabetic: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    var isNumberWithPoint: Bool {
        return !isEmpty && range(of: "[^0-9.-]", options: .regularExpression) == nil
    }

    var isGPS: Bool {
        if !isEmpty, contains(",") {
            let arr = components(separatedBy: ",")
            if arr.count == 2 {
                var bol = true
                arr.forEach { (item) in
                    if !item.isNumberWithPoint {
                        bol = false
                    }
                }
                return bol
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

extension UIApplication {
    static var currentViewController: UIViewController? {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }

        return getCurrentViewController(from: rootViewController)
    }

    private static func getCurrentViewController(from viewController: UIViewController) -> UIViewController {
        switch viewController {
        case is UINavigationController:
            return getCurrentViewController(from: (viewController as! UINavigationController).visibleViewController!)
        case is UITabBarController:
            return getCurrentViewController(from: (viewController as! UITabBarController).selectedViewController!)
        default:
            if let presentedViewController = viewController.presentedViewController {
                return getCurrentViewController(from: presentedViewController)
            } else {
                return viewController
            }
        }
    }
}
