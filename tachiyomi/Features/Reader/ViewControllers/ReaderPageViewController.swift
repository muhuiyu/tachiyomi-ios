//
//  ReaderPageViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import Kingfisher

class ReaderPageViewController: ViewController {

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    var imageURLString: String = "" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.imageView.kf.setImage(with: URL(string: self.imageURLString))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
}


// MARK: - View Config
extension ReaderPageViewController {
    private func configureViews() {
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3

        view.addSubview(scrollView)
        view.backgroundColor = .clear
    }
    private func configureConstraints() {
        imageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(scrollView)
        }
        scrollView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension ReaderPageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
