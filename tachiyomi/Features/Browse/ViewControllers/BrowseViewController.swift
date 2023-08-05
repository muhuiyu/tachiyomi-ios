//
//  BrowseViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

class BrowseViewController: Base.MVVMViewController<BrowseViewModel> {
    // MARK: - Views
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // TODO: - Implement source search
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
}

// MARK: - View Config
extension BrowseViewController {
    private func configureViews() {
        configureNavigationBar()
        tableView.register(BrowseSourceCell.self, forCellReuseIdentifier: BrowseSourceCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func configureNavigationBar() {
        let filterBarItem = UIBarButtonItem(image: UIImage(systemName: Icons.line3HorizontalDecrease),
                                            style: .plain,
                                            target: self,
                                            action: #selector(didTapFilter))
        navigationItem.rightBarButtonItem = filterBarItem
    }
}

// MARK: - Handlers
extension BrowseViewController {
    @objc
    private func didTapFilter() {
        // TODO: -
    }
}

// MARK: - TableView DataSource and Delegate
extension BrowseViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sourceSections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sourceSections[section].1.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sourceSections[section].0.localizedName
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
        let source = viewModel.getSource(at: indexPath)
        let sourceViewModel = SourceViewModel(appCoordinator: self.appCoordinator, source: source)
        let viewController = SourceCatalogViewController(appCoordinator: self.appCoordinator,
                                                         viewModel: sourceViewModel,
                                                         source: source)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
