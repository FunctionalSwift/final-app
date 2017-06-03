// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

extension String {

    func dateFromString() -> Date {

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:SS"

        if let date = formatter.date(from: self) {
            return date
        }

        return Date.distantPast
    }
}

extension Date {

    func stringFromDate() -> String? {

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:SS"

        return formatter.string(from: self)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0xFF00) >> 8
        let b = rgbValue & 0xFF

        self.init(
            red: CGFloat(r) / 0xFF,
            green: CGFloat(g) / 0xFF,
            blue: CGFloat(b) / 0xFF, alpha: 1
        )
    }
}

func JSONString(_ object: AnyObject?) -> String? {
    return object as? String
}

func JSONInt(_ object: AnyObject?) -> Int? {
    return object as? Int
}

func JSONBool(_ object: AnyObject?) -> Bool? {
    return object as? Bool
}

func JSONArray(_ object: AnyObject?) -> [[String: AnyObject]]? {
    return object as? [[String: AnyObject]]
}

func JSONStringArray(_ object: AnyObject?) -> [String]? {
    return object as? [String]
}

func colorizeDate(date: Date) -> NSAttributedString {

    return NSAttributedString(string: date.stringFromDate()!, attributes:
        date < Date() ? [NSAttributedStringKey.foregroundColor: UIColor(hex: "ff0027")] :
        [NSAttributedStringKey.foregroundColor: UIColor(hex: "64a900s")])
}

func stringFromDate(_ date: Date) -> String {

    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:SS"

    return formatter.string(from: date)
}
