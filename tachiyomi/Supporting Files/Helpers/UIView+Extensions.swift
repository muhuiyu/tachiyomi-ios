//
//  UIView+Extensions.swift
//  Fastiee
//
//  Created by Mu Yu on 6/27/22.
//

import UIKit

extension UIView {
    func fadeIn(_ duration: TimeInterval? = 0.2, completion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = completion { complete() }
                       }
        )
    }
    func fadeOut(_ duration: TimeInterval? = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = completion { complete() }
                       }
        )
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
