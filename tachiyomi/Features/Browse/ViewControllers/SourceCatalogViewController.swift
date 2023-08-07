//
//  SourceCatalogViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

class SourceCatalogViewController: Base.MVVMViewController<SourceViewModel> {
    // MARK: - Views
    private let searchController = UISearchController()
    private let segmentControl: UISegmentedControl
    private let layoutFlow = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutFlow)
    private let spinner = UIActivityIndicatorView(style: .large)
    
    init(appCoordinator: AppCoordinator? = nil, viewModel: SourceViewModel, sourceID: String) {
        // TODO: - update segment control based on sources
        self.segmentControl = UISegmentedControl(items: ["Popular", "Latest"])
        super.init(appCoordinator: appCoordinator, viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - View Config
extension SourceCatalogViewController {
    private func configureViews() {
        configureNavigationBar()
        
        // Search bar
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search mangas..."
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        
        // SegmentControl
        segmentControl.selectedSegmentIndex = 0
        view.addSubview(segmentControl)
        
        // CollectionView
        layoutFlow.scrollDirection = .vertical
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MangaPreviewCell.self, forCellWithReuseIdentifier: MangaPreviewCell.reuseID)
        collectionView.prefetchDataSource = self
        view.addSubview(collectionView)
        spinner.startAnimating()
        view.addSubview(spinner)
    }
    private func configureConstraints() {
        segmentControl.snp.remakeConstraints { make in
            make.top.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.centerX.equalToSuperview()
        }
        collectionView.snp.remakeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(Constants.Spacing.medium)
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
        spinner.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureNavigationBar() {
        title = viewModel.getSourceName()
        
        // filter, more
        let viewBarItem = UIBarButtonItem(image: UIImage(systemName: Icons.squareGrid2x2),
                                          style: .plain,
                                          target: self,
                                          action: #selector(didTapChangeView))
        let websiteBarItem = UIBarButtonItem(image: UIImage(systemName: Icons.globe),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapOpenWebsite))
        
        navigationItem.rightBarButtonItems = [ viewBarItem, websiteBarItem ]
    }
    private func configureBindings() {
        viewModel.sourceMangas
            .asObservable()
            .subscribe { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .asObservable()
            .subscribe { isLoading in
                DispatchQueue.main.async { [weak self] in
                    self?.spinner.isHidden = !isLoading
                    if isLoading {
                        self?.spinner.startAnimating()
                    } else {
                        self?.spinner.stopAnimating()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Handlers
extension SourceCatalogViewController {
    @objc
    private func didTapChangeView() {
        
    }
    
    @objc
    private func didTapOpenWebsite() {

    }
}

// MARK: - CollectionView dataSource and delegate
extension SourceCatalogViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sourceMangas.value.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MangaPreviewCell.reuseID, for: indexPath) as? MangaPreviewCell else { return UICollectionViewCell() }
        cell.manga = viewModel.sourceMangas.value[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        let mangaViewModel = MangaViewModel(appCoordinator: self.appCoordinator, sourceID: viewModel.sourceID)
        mangaViewModel.manga.accept(viewModel.sourceMangas.value[indexPath.row])
        let viewController = MangaDetailsViewController(appCoordinator: self.appCoordinator,
                                                        viewModel: mangaViewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("prefetchItemsAt", indexPaths)
        let newRowsToFetch = indexPaths.filter({ $0.row >= viewModel.sourceMangas.value.count - 1 })
        if newRowsToFetch.isEmpty {
            return
        }
        if !viewModel.hasNextPage { return }
        viewModel.fetchNextPage()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let windowWidth = view.window?.windowScene?.screen.bounds.width else { return CGSize(width: 100, height: 150) }
        let margin = view.layoutMargins.left
        
        // n * (width + margin) <= windowwidth - margin
        // width >= 185, 2 <= n <= 5
        let numberOfItems = calculateMaxNumberOfItemsInRow(windowWidth: windowWidth, margin: margin)
        let width = (windowWidth - margin) / CGFloat(numberOfItems) - margin
        return CGSize(width: width, height: width * 1.5)
    }
    private func calculateMaxNumberOfItemsInRow(windowWidth: Double, margin: Double) -> Int {
        let width = 185.0 // the minimum value for width
        let approximateN = (windowWidth - margin) / (width + margin)
        let n = Int(approximateN.rounded(.down)) // round down to nearest whole number
        if n > 5 { return 5 }   // the maximum value for n
        if n < 2 { return 2 }   // the minimum value for n
        return n
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let addToLibrary = UIAction(title: "Add to library", image: UIImage(systemName: Icons.plus)) { action in
                guard let indexPath = indexPaths.first else { return }
                self.viewModel.addMangaToLibary(at: indexPath)
            }
            // Create a UIMenu with all the actions as children
            return UIMenu(title: "", children: [addToLibrary])
        }
    }
}

extension SourceCatalogViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.searchMangas(for: query)
    }
}
