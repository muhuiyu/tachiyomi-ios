//
//  BrowseViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

class BrowseViewController: Base.MVVMViewController<BrowseViewModel> {
    // MARK: - Views
    private let segmentControl = UISegmentedControl(items: ["Recent", "All"])
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        
        viewModel.updateSources(to: .recent)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - View Config
extension BrowseViewController {
    private func configureViews() {
        configureNavigationBar()
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(didChangeIndex(_:)), for: .valueChanged)
        view.addSubview(segmentControl)
        tableView.register(BrowseSourceCell.self, forCellReuseIdentifier: BrowseSourceCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        segmentControl.snp.remakeConstraints { make in
            make.top.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(Constants.Spacing.medium)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func configureNavigationBar() {
        let filterBarItem = UIBarButtonItem(image: UIImage(systemName: Icons.line3HorizontalDecrease),
                                            style: .plain,
                                            target: self,
                                            action: #selector(didTapFilter))
        navigationItem.rightBarButtonItem = filterBarItem
    }
    private func configureBindings() {
        viewModel.sections
            .asObservable()
            .subscribe { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Handlers
extension BrowseViewController {
    @objc
    private func didTapFilter() {
        // TODO: -
    }
    @objc
    private func didChangeIndex(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.updateSources(to: .recent)
        case 1:
            viewModel.updateSources(to: .all)
        default:
            break
        }
    }
}

// MARK: - TableView DataSource and Delegate
extension BrowseViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows(at: section)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getTitle(at: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BrowseSourceCell.reuseID, for: indexPath) as? BrowseSourceCell else { return UITableViewCell() }
        cell.title = viewModel.getSourceName(at: indexPath)
        cell.subtitle = viewModel.getSourceLanguage(at: indexPath)
        let image = UIImage(named: viewModel.getSourceThumbnailURL(at: indexPath))
        cell.logo = image
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let sourceID = viewModel.getSourceID(at: indexPath)
        let sourceViewModel = SourceViewModel(appCoordinator: self.appCoordinator, sourceID: sourceID)
        let viewController = SourceCatalogViewController(appCoordinator: self.appCoordinator,
                                                         viewModel: sourceViewModel,
                                                         sourceID: sourceID)
        navigationController?.pushViewController(viewController, animated: true)
        
        if viewModel.mode == .all {
            // Save source to recent used
            viewModel.saveSource(at: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard viewModel.mode == .recent else { return nil }
        let destructiveAction = UIContextualAction(style: .destructive, title: "Remove from list") { [weak self] (_, _, _) in
            self?.viewModel.unsaveSource(at: indexPath)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        destructiveAction.image = UIImage(systemName: Icons.trashFill)
        let configuration = UISwipeActionsConfiguration(actions: [destructiveAction])
        return configuration
    }
}
