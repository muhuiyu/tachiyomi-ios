//
//  LibraryViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import SkeletonView

class LibraryViewController: Base.MVVMViewController<LibraryViewModel> {
    // MARK: - Views
    private let searchController = UISearchController()
    private let layoutFlow = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutFlow)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadData()
        tabBarController?.tabBar.isHidden = false
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - View Config
extension LibraryViewController {
    private func configureViews() {
        configureNavigationBar()
        
        // Search bar
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        // CollectionView
        layoutFlow.scrollDirection = .vertical
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MangaPreviewCell.self, forCellWithReuseIdentifier: MangaPreviewCell.reuseID)
        view.addSubview(collectionView)
    }
    private func configureConstraints() {
        collectionView.snp.remakeConstraints { make in
            make.edges.equalTo(view.layoutMarginsGuide)
        }
    }
    private func configureNavigationBar() {
        // search, filter, more
        let searchBarItem = UIBarButtonItem(image: UIImage(systemName: Icons.magnifyingglass),
                                            style: .plain,
                                            target: self,
                                            action: #selector(didTapSearch))
        let filterBarItem = UIBarButtonItem(image: UIImage(systemName: Icons.line3HorizontalDecrease),
                                            style: .plain,
                                            target: self,
                                            action: #selector(didTapFilter))
        
        navigationItem.rightBarButtonItems = [ searchBarItem, filterBarItem ]
    }
    private func configureBindings() {
        viewModel.filteredMangas
            .asObservable()
            .subscribe { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Handlers
extension LibraryViewController {
    @objc
    private func didTapSearch() {
        
    }
    
    @objc
    private func didTapFilter() {
        
    }
    
    @objc
    private func didTapMore() {
        
    }
}

// MARK: - CollectionView dataSource and delegate
extension LibraryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.isLoading.value ? viewModel.getNumberOfLibraryMangas() : viewModel.filteredMangas.value.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MangaPreviewCell.reuseID, for: indexPath) as? MangaPreviewCell else { return UICollectionViewCell() }
        cell.isSkeletonable = true
        if viewModel.isLoading.value {
            cell.showSkeleton(animated: true, delay: 0.5)
        } else {
            cell.hideSkeleton()
            cell.manga = viewModel.filteredMangas.value[indexPath.row]
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        let manga = viewModel.filteredMangas.value[indexPath.row]
        let mangaViewModel = MangaViewModel(appCoordinator: self.appCoordinator, sourceID: manga.sourceID)
        mangaViewModel.manga.accept(manga)
        let viewController = MangaDetailsViewController(appCoordinator: self.appCoordinator,
                                                        viewModel: mangaViewModel)
        navigationController?.pushViewController(viewController, animated: true)
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
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                // TODO: - add share
//                guard
//                    let indexPath = indexPaths.first,
//                    let urlString = self.viewModel.filteredMangas.value[indexPath.row].url,
//                    let data = URL(string: urlString)
//                else { return }
//                let viewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
//                viewController.popoverPresentationController?.sourceView = self.view
//                self.present(viewController, animated: true)
            }

            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                guard let indexPath = indexPaths.first else { return }
                self.viewModel.deleteMangaFromLibrary(at: indexPath)
                DispatchQueue.main.async { [weak self] in
                    self?.searchController.dismiss(animated: true)
                }
            }

            // Create a UIMenu with all the actions as children
            return UIMenu(title: "", children: [share, delete])
        }
    }
}

extension LibraryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.filterManga(with: query)
    }
}

extension LibraryViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return MangaPreviewCell.reuseID
    }
}
