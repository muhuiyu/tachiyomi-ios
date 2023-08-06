//
//  ReaderPageViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import RxRelay
import RxSwift
import Kingfisher

class ReaderPageViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    
    private let readerViewModel: ReaderViewModel
    let pageIndex: Int
    
    init(readerViewModel: ReaderViewModel, pageIndex: Int) {
        self.readerViewModel = readerViewModel
        self.pageIndex = pageIndex
    }

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        
        readerViewModel
            .pages
            .asObservable()
            .subscribe { [weak self] _ in
                self?.reconfigureImage()
            }
            .disposed(by: disposeBag)
    }
}


// MARK: - View Config
extension ReaderPageViewController {
    private func configureViews() {
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3

        view.addSubview(scrollView)
        view.backgroundColor = .clear
        
        reconfigureImage()
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
    private func reconfigureImage() {
        guard let imageURLString = readerViewModel.getImageURL(at: pageIndex) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageView.kf.setImage(with: URL(string: imageURLString), placeholder: UIImage(systemName: Icons.photoFill))
        }
    }
}

extension ReaderPageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
