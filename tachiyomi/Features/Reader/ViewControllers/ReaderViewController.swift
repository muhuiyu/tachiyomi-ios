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
    
    // MARK: - Views
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let pageNumberLabel = UILabel()
    private let slider = UISlider()
    
    private var isLightOn: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.view.backgroundColor = self.isLightOn ? .white : .black
                    self.navigationController?.navigationBar.backgroundColor = self.isLightOn ? .white : .black
                    self.navigationController?.isNavigationBarHidden = !self.isLightOn
                    self.slider.isHidden = !self.isLightOn
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.saveCurrentSession()
    }
}

// MARK: - Handlers
extension ReaderViewController {
    @objc
    private func didTapClose() {
        self.dismiss(animated: true)
    }
    @objc
    private func didTapInView() {
        isLightOn = !isLightOn
    }
    @objc
    private func didDragSlider(_ sender: UISlider) {
        var currentIndex: Float = 0
        if sender.value < 0 {
            currentIndex = 0
        } else if sender.value > Float(viewModel.numberOfPages-1) {
            currentIndex = Float(viewModel.numberOfPages-1)
        } else {
            currentIndex = sender.value.rounded()
        }
        
        sender.value = currentIndex
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if Int(currentIndex) != viewModel.currentPage.value {
            changePageViewControllerContent(to: Int(currentIndex))
            viewModel.currentPage.accept(Int(currentIndex))
        }
    }
}

// MARK: - View Config
extension ReaderViewController {
    private func configureViews() {
        configureNavigationBar()
        
        // pageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        view.backgroundColor = .black
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        // page number
        pageNumberLabel.font = .bodyBold
        pageNumberLabel.textColor = .label
        view.addSubview(pageNumberLabel)
        
        // slider
        slider.isHidden = true
        slider.transform = CGAffineTransform(scaleX: -1, y: 1)
        slider.isContinuous = false
        slider.minimumValue = 0
        slider.maximumValue = 100   // default number
        slider.addTarget(self, action: #selector(didDragSlider(_:)), for: [.touchDragEnter, .touchDragInside])
        view.addSubview(slider)
    }
    private func configureConstraints() {
        pageViewController.view.snp.remakeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.layoutMarginsGuide).inset(72)
        }
        pageNumberLabel.snp.remakeConstraints { make in
            make.leading.equalTo(view.layoutMarginsGuide).inset(Constants.Spacing.large)
            make.centerY.equalTo(slider)
        }
        slider.snp.remakeConstraints { make in
            make.leading.equalTo(pageNumberLabel.snp.trailing).offset(Constants.Spacing.medium)
            make.trailing.equalTo(view.layoutMarginsGuide).inset(Constants.Spacing.large)
            make.bottom.equalTo(view.layoutMarginsGuide).inset(Constants.Spacing.enormous)
            make.height.equalTo(30)
        }
    }
    private func configureBindings() {
        viewModel.currentPage
            .asObservable()
            .subscribe { [weak self] value in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.title = "\(self.viewModel.chapter.value?.name ?? "")"
                    self.configurePageNumberLabel()
                    self.updateSliderValue(to: value)
                    
                    // update pageViewController if it's not synced
                    if self.viewModel.currentPageViewControllerIndex != value {
                        changePageViewControllerContent(to: value)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.isNavigationBarHidden = true
        let closeButton = UIBarButtonItem(image: UIImage(systemName: Icons.xmark), style: .plain, target: self, action: #selector(didTapClose))
        navigationItem.leftBarButtonItem = closeButton
    }
    private func configurePageNumberLabel() {
        pageNumberLabel.text = "\(viewModel.currentPage.value + 1) / \(viewModel.numberOfPages)"
    }
    private func updateSliderValue(to currentPage: Int) {
        slider.maximumValue = Float(viewModel.numberOfPages-1)
        // update slider if it's not synced
        if Int(slider.value) != currentPage {
            slider.setValue(Float(currentPage), animated: true)
        }
    }
    private func configureGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInView))
        view.addGestureRecognizer(tapRecognizer)
    }
    private func changePageViewControllerContent(to pageIndex: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let viewController = self.viewModel.getReaderPageViewController(at: pageIndex) {
                self.pageViewController.setViewControllers([ viewController ], direction: .forward, animated: false)
                self.viewModel.currentPageViewControllerIndex = pageIndex
            } else {
                let viewController = self.viewModel.shouldShowNoPageFound ? ReaderNoPageFoundViewController() : ReaderLoadingViewController()
                self.pageViewController.setViewControllers([ viewController ], direction: .forward, animated: false)
                self.viewModel.currentPageViewControllerIndex = nil
            }
        }
    }
}

// MARK: - PageViewController delegate and dataSource
extension ReaderViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // reach last page
        if let currentIndex = viewModel.currentPageViewControllerIndex, currentIndex >= viewModel.numberOfPages - 1 {
            let viewController = ReaderEndPageViewController(canLoadNextChapter: viewModel.canLoadNextChapter)
            viewController.delegate = self
            viewModel.currentPageViewControllerIndex = viewModel.numberOfPages
            return viewController
        } else {
            return viewModel.getPreviousReaderPageViewController()
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewModel.getNextReaderPageViewController()
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard
            completed,
            let viewControllers = pageViewController.viewControllers as? [ReaderPageViewController]
        else { return }
        
        let currentIndex = viewControllers[0].pageIndex
        viewModel.currentPage.accept(currentIndex)
        viewModel.currentPageViewControllerIndex = currentIndex
    }
}

// MARK: - ReaderEndPageViewControllerDelegate
extension ReaderViewController: ReaderEndPageViewControllerDelegate {
    func readerEndPageViewControllerDidTapNextChapter() {
        viewModel.loadNextChapter()
    }
    func readerEndPageViewControllerDidTapRestart() {
        viewModel.restartChapter()
    }
    func readerEndPageViewControllerDidTapClose() {
        self.dismiss(animated: true)
    }
}

