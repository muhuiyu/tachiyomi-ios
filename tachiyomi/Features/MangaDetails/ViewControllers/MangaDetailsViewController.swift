//
//  MangaDetailsViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxSwift
import RxRelay

class MangaDetailsViewController: Base.MVVMViewController<MangaViewModel> {
    
    // MARK: - Download
    private var downloadingImageURLs = [String: DownloadImageEntry]()
    private var downloadTasks: [String: URLSession] = [:]
    
    // MARK: - Views
    private let tableView = UITableView()
    private let scrollToTopButton = ScrollToTopButton()
    private let startButton = TextButton(buttonType: .primary)
    private let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        
        viewModel.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.restoreLastReadChapter()
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - Handlers
extension MangaDetailsViewController {
    private func didTapScrollToTop() {
        tableView.scrollToRow(at: TableViewConstants.headerIndexPath, at: .top, animated: true)
    }
    private func didTapStart(from chapterIndex: Int) {
        guard let chapters = viewModel.manga.value?.chapters else { return }
        let readerViewModel = ReaderViewModel(appCoordinator: self.appCoordinator,
                                              chapters: chapters,
                                              initailChapterIndex: chapterIndex,
                                              sourceID: viewModel.sourceID)
        let navigationController = ReaderViewController(appCoordinator: self.appCoordinator,
                                                        viewModel: readerViewModel).embedInNavgationController()
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

// MARK: - View Config
extension MangaDetailsViewController {
    private func configureViews() {
        tableView.scrollsToTop = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MangaDetailsHeaderCell.self, forCellReuseIdentifier: MangaDetailsHeaderCell.reuseID)
        tableView.register(MangaDetailsChapterCell.self, forCellReuseIdentifier: MangaDetailsChapterCell.reuseID)
        view.addSubview(tableView)
        
        scrollToTopButton.tapHandler = { [weak self] in
            self?.didTapScrollToTop()
        }
        scrollToTopButton.layer.cornerRadius = Constants.TextButton.cornerRadius
        scrollToTopButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        view.addSubview(scrollToTopButton)
        
        startButton.text = "Start"
        startButton.buttonColor = .systemBlue
        startButton.tapHandler = { [weak self] in
            guard let self = self else { return }
            self.didTapStart(from: self.viewModel.lastReadChapterIndex.value ?? self.viewModel.firstChapterIndex)
        }
        view.addSubview(startButton)
        spinner.startAnimating()
        view.addSubview(spinner)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        scrollToTopButton.snp.remakeConstraints { make in
            make.leading.bottom.equalTo(view.layoutMarginsGuide)
            make.size.equalTo(Constants.TextButton.Height.medium)
        }
        startButton.snp.remakeConstraints { make in
            make.height.bottom.equalTo(scrollToTopButton)
            make.leading.equalTo(scrollToTopButton.snp.trailing).offset(Constants.Spacing.small)
            make.trailing.equalTo(view.layoutMarginsGuide)
        }
        spinner.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureBindings() {
        viewModel.manga
            .asObservable()
            .subscribe { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .asObservable()
            .subscribe { [weak self] isLoading in
                self?.configureVisibility(isLoading)
            }
            .disposed(by: disposeBag)
        
        viewModel.lastReadChapterIndex
            .asObservable()
            .subscribe { [weak self] _ in
                self?.reloadStartButton()
            }
            .disposed(by: disposeBag)
    }
    
    private func configureVisibility(_ isLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.isHidden = !isLoading
            self?.tableView.isHidden = isLoading
            self?.startButton.isHidden = isLoading
            self?.scrollToTopButton.isHidden = isLoading
            if isLoading {
                self?.spinner.startAnimating()
            } else {
                self?.spinner.stopAnimating()
            }
        }
    }
    
    private func reloadStartButton() {
        DispatchQueue.main.async { [weak self] in
            if let name = self?.viewModel.lastReadChapterName {
                self?.startButton.text = "Continue from \(name)"
            }
        }
    }
}
// MARK: - TableView DataSource and Delegate
extension MangaDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    struct TableViewConstants {
        static var headerIndexPath: IndexPath { IndexPath(row: 0, section: 0) }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (viewModel.manga.value?.chapters.count ?? 0)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == TableViewConstants.headerIndexPath {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MangaDetailsHeaderCell.reuseID, for: indexPath) as? MangaDetailsHeaderCell else {
                return UITableViewCell()
            }
            viewModel.manga.bind(to: cell.manga).disposed(by: disposeBag)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MangaDetailsChapterCell.reuseID, for: indexPath) as? MangaDetailsChapterCell else {
                return UITableViewCell()
            }
            cell.indexPath = indexPath
            let chapter = viewModel.manga.value?.chapters[indexPath.row - 1]
            cell.isDownloaded = viewModel.canRestoreSavedChapter(for: chapter)
            cell.chapter = chapter
            cell.delegate = self
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // add extra padding at the end of the table
        let view = UIView()
        view.snp.remakeConstraints { make in
            make.height.equalTo(48)
        }
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        guard indexPath != TableViewConstants.headerIndexPath else { return }
        didTapStart(from: indexPath.row-1)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == TableViewConstants.headerIndexPath {
            return nil
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - CellDelegate
extension MangaDetailsViewController: MangaDetailsHeaderCellDelegate, MangaDetailsChapterCellDelegate {
    func mangaDetailsHeaderCellDidTapAddToLibrary() {
        viewModel.addToLibrary()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    func mangaDetailsHeaderCellDidTapGoToWebsite() {
        guard let urlString = viewModel.manga.value?.url, let url = URL(string: urlString) else {
            print("URL not found")
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    func mangaDetailsChapterCellDidTapDownload(_ cell: MangaDetailsChapterCell, at indexPath: IndexPath) {
        cell.downloadState = .downloading
        Task {
            await download(cell.chapter, at: indexPath)
        }
    }
}

// MARK: - Download chapters
extension MangaDetailsViewController {
    private func download(_ chapter: SourceChapter?, at indexPath: IndexPath) async {
        guard let chapter = chapter else { return }
        
        viewModel.createDirectoryIfNeeded(for: chapter)
        
        // Check if a download task for this chapter already exists
        if let existingSession = downloadTasks[chapter.url] {
            existingSession.invalidateAndCancel()
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        downloadTasks[chapter.url] = session    // Store the URLSession in the dictionary with chapter.url as the key
        let pages = await viewModel.fetchPages(for: chapter)
        updateNumberOfTotalPages(forCellAt: indexPath, totalPage: pages.count)
        
        do {
            try await withThrowingTaskGroup(of: (Int, URL, (URL, URLResponse)).self) { group in
                for (i, page) in pages.enumerated() {
                    guard let imageURL = page.imageURL, let url = URL(string: imageURL) else {
                        return
                    }
                    group.addTask {
                        return (i, url, try await session.download(from: url))
                    }
                }
                for try await (pageIndex, url, (location, _)) in group {
                    if let targetPath = chapter.getLocalStoragePath()?.appendingPathComponent(parseFileName(from: url, at: pageIndex)) {
                        try FileManager.default.moveItem(at: location, to: targetPath)
                    }
                    downloadTasks[chapter.url]?.finishTasksAndInvalidate()
                    updateProgress(forCellAt: indexPath)
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func updateNumberOfTotalPages(forCellAt indexPath: IndexPath, totalPage: Int) {
        DispatchQueue.main.async { [weak self] in
            if let cell = self?.tableView.cellForRow(at: indexPath) as? MangaDetailsChapterCell {
                cell.totalPages = totalPage
            }
        }
    }
    
    private func updateProgress(forCellAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            if let cell = self?.tableView.cellForRow(at: indexPath) as? MangaDetailsChapterCell {
                cell.numberOfDownloadedItems += 1
            }
        }
    }
    
    private func parseFileName(from url: URL, at pageIndex: Int) -> String {
        if let fileExtension = url.lastPathComponent.components(separatedBy: ".").last {
            return String(pageIndex) + "." +  fileExtension
        } else {
            return url.lastPathComponent
        }
    }
    
    private struct DownloadImageEntry {
        let chapter: SourceChapter
        let pageIndex: Int
        let cellIndexPath: IndexPath
    }
}
