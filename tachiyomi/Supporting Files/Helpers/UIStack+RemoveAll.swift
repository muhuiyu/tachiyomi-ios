//
//  UIStack+RemoveAll.swift
//  Money Tracker
//
//  Created by Grace, Mu-Hui Yu on 7/31/23.
//

import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }

}
