//
//  ReaderLoadingViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit

class ReaderLoadingViewController: ViewController {
    
    private let spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        spinner.color = .white
        view.backgroundColor = .black
        view.addSubview(spinner)
        
        spinner.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
