//
//  ReaderViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import RxSwift
import RxRelay

class ReaderViewController: Base.MVVMViewController<ReaderViewModel> {
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    var isLightOn: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.view.backgroundColor = self.isLightOn ? .white : .black
                    self.navigationController?.navigationBar.backgroundColor = self.isLightOn ? .white : .black
                    self.navigationController?.isNavigationBarHidden = !self.isLightOn
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureGestures()
        configureBindings()
    }
    
}

// MARK: - View Config
extension ReaderViewController {
    private func configureViews() {
        configureNavigationBar()
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        view.backgroundColor = .black
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    private func configureConstraints() {
        pageViewController.view.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func configureBindings() {
        viewModel.pages
            .asObservable()
            .subscribe { [weak self] _ in
                self?.configurePageContent()
            }
            .disposed(by: disposeBag)
    }
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.isNavigationBarHidden = true
        let closeButton = UIBarButtonItem(image: UIImage(systemName: Icons.xmark), style: .plain, target: self, action: #selector(didTapClose))
        navigationItem.leftBarButtonItem = closeButton
    }
    private func configureTitleValue() {
        title = "\(viewModel.chapter.value?.name ?? "") | page \(viewModel.currentPage+1)/ \(viewModel.pages.value.count)"
    }
    private func configurePageContent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.configureTitleValue()
            
            if let imageURLString = self.viewModel.getFirstPageImageURLString() {
                let viewController = ReaderPageViewController()
                viewController.imageURLString = imageURLString
                self.pageViewController.setViewControllers([ viewController ], direction: .forward, animated: false)
            } else {
                let viewController = self.viewModel.shouldShowNoPageFound ? ReaderNoPageFoundViewController() : ReaderLoadingViewController()
                self.pageViewController.setViewControllers([ viewController ], direction: .forward, animated: false)
            }
        }
    }
    @objc
    private func didTapClose() {
        self.dismiss(animated: true)
    }
    
    private func configureGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInView))
        view.addGestureRecognizer(tapRecognizer)
    }
    @objc
    private func didTapInView() {
        isLightOn = !isLightOn
    }
}

// MARK: - PageViewController delegate and dataSource
extension ReaderViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            !viewModel.pages.value.isEmpty,
            let imageURLString = viewModel.getPreviousPageImageURLString()
        else { return nil }
        let viewController = ReaderPageViewController()
        viewController.imageURLString = imageURLString
        return viewController
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            !viewModel.pages.value.isEmpty,
            let imageURLString = viewModel.getNextPageImageURLString()
        else { return nil }
        let viewController = ReaderPageViewController()
        viewController.imageURLString = imageURLString
        return viewController
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed,
              let viewControllers = pageViewController.viewControllers as? [ReaderPageViewController],
              let currentIndex = viewModel.pages.value.firstIndex(where: { page in
                  page.imageURL == viewControllers[0].imageURLString
              })
        else { return }
        viewModel.currentPage = currentIndex
        configureTitleValue()
    }
}

