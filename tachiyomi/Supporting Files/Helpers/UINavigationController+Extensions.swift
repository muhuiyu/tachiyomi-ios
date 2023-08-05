//
//  UINavigationController+Extensions.swift
//  Why am I so poor
//
//  Created by Mu Yu on 7/4/22.
//

import UIKit

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    func navigationBarColor(_ color: UIColor) {
        
    }
    
    func removeBottomLine() {
        navigationBar.shadowImage = UIImage()
    }
    
    func configureBackButton(_ image: UIImage, _ title: String? = nil, tintColor: UIColor? = nil) {
        navigationBar.backIndicatorImage = image
        navigationBar.backIndicatorTransitionMaskImage = image
        navigationBar.tintColor = tintColor ?? .white
        navigationBar.backItem?.title = title
        navigationBar.backItem?.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        navigationBar.items?.first?.title = ""  // what is this?
    }
    
    /// Finds the view controller instance from the app's navigation stack
    /// - Parameters:
    ///     - class: Class type of the view controller
    /// - Returns: The view controller object of the specified type, returns `nil` if no such view controller is found
    func findViewController<T: UIViewController>(_ class: T.Type) -> T? {
        let viewControllers = self.viewControllers.reversed()
        for viewController in viewControllers {
            if viewController is T {
                return viewController as? T
            }
        }
        return nil
    }
}

extension UINavigationItem {
    internal enum ItemPosition {
        case left
        case right
    }
    func setTitle(_ text: String, color: UIColor = .label) {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = color
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = true
        titleView = label
        label.sizeToFit()
    }
    func setBarButtonItem(at position: ItemPosition, with title: String? = nil, isBold: Bool = false, image: UIImage? = nil, target: Any?, action: Selector) {
        let item: UIBarButtonItem
        if let image = image {
            item = UIBarButtonItem(image: image, style: isBold ? .done : .plain, target: target, action: action)
        } else {
            item = UIBarButtonItem(title: title, style: isBold ? .done : .plain, target: target, action: action)
//            item.setTitleTextAttributes([
//                NSAttributedString.Key.font: isBold ? .bodyBold : UIFont.body,
//                NSAttributedString.Key.foregroundColor: UIColor.brand.primary,
//            ], for: .normal)
//            item.setTitleTextAttributes([
//                NSAttributedString.Key.font: isBold ? .bodyBold : UIFont.body,
//                NSAttributedString.Key.foregroundColor: UIColor.tertiaryLabel
//            ], for: .disabled)
        }
        switch position {
        case .left:
            leftBarButtonItems = [item]
        case .right:
            rightBarButtonItems = [item]
        }
    }
}

extension UINavigationBar {
    
}
