//
//  UIColor+Extensions.swift
//  Fastiee
//
//  Created by Mu Yu on 6/27/22.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        guard hex.count == 6 else { fatalError() }
        let redString = hex.prefix(2)
        let greenString = hex.prefix(4).suffix(2)
        let blueString = hex.suffix(2)
        
        guard let red = Int(redString, radix: 16),
              let green = Int(greenString, radix: 16),
            let blue = Int(blueString, radix: 16) else {
                fatalError()
        }
        
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }
}
