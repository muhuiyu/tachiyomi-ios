//
//  ViewController.swift
//  Money Tracker
//
//  Created by Grace, Mu-Hui Yu on 7/31/23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)  // for all of the children this is unavailable, unavailable on all iOS versions. Can be used for macOS/iOS
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
    }
}
