//
//  ReaderViewModel.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import RxSwift
import RxRelay

class ReaderViewModel: Base.ViewModel {
    let chapterIndex = BehaviorRelay(value: 0)
    
    let chapter: BehaviorRelay<SourceChapter?> = BehaviorRelay(value: nil)
    let pages: BehaviorRelay<[ChapterPage]> = BehaviorRelay(value: [])
    let chapters: [SourceChapter]
    private let source: Source
    
    var currentPage = BehaviorRelay(value: 0)
    var currentPageViewControllerIndex = -1
    private(set) var shouldShowNoPageFound = false
    
    init(appCoordinator: AppCoordinator? = nil, chapters: [SourceChapter], source: Source) {
        self.source = source
        self.chapters = chapters
        super.init(appCoordinator: appCoordinator)
        configureBindings()
    }
}

extension ReaderViewModel {
    var isPagesEmpty: Bool {
        return pages.value.isEmpty
    }
    var numberOfPages: Int {
        return pages.value.count
    }
    var isReadingLastPage: Bool {
        return currentPage.value == numberOfPages
    }
}

// MARK: - Data
extension ReaderViewModel {
    func reloadData() {
        guard let chapterURL = chapter.value?.url else { return }
        Task {
            switch source {
            case .senManga:
                let result = await SenManga.shared.getChapterPages(from: chapterURL)
                switch result {
                case .failure(let error):
                    print("Error: ", error.localizedDescription)
                    self.shouldShowNoPageFound = true
                    pages.accept([])
                case .success(let fetchedPages):
                    pages.accept(fetchedPages)
                }
                restoreLastSession()
            case .ganma:
                guard let page = chapter.value?.ganmaPage else { return }
                let fetchedPages = Ganma.shared.getChapterPages(from: page)
                pages.accept(fetchedPages)
                restoreLastSession()
            case .shonenJumpPlus:
                return 
            }
        }
    }
    var canLoadNextChapter: Bool {
        return chapterIndex.value < chapters.count - 1
    }
    func loadNextChapter() {
        if canLoadNextChapter {
            chapterIndex.accept(chapterIndex.value + 1)
        }
    }
    func restoreLastSession() {
        guard !pages.value.isEmpty, let chapterURL = chapter.value?.url else { return }
        if let pageNumber = LocalStorage.shared.getLastReadPageNumber(for: chapterURL) {
            currentPage.accept(pageNumber)
        } else {
            currentPage.accept(0)
        }
        print("start from \(currentPage.value)")
    }
    func saveCurrentSession() {
        guard let chapterURL = chapter.value?.url, let mangaURL = chapter.value?.mangaURL else { return }
        if isReadingLastPage {
            let nextChapterURL = chapters[chapterIndex.value+1].url
            LocalStorage.shared.clearLastReadPageNumber(for: chapterURL)    // remove page bookmark from current chapter
            LocalStorage.shared.saveLastReadPageNumber(currentPage.value, for: nextChapterURL) // save next chapter instead
        }
        LocalStorage.shared.saveLastReadChapterURL(chapterURL, for: mangaURL)
        print("end at \(currentPage.value)")
    }
}

// MARK: - Navigation
extension ReaderViewModel {
    func restartChapter() {
        currentPage.accept(0)
    }
    func getReaderPageViewController(at pageIndex: Int) -> ReaderPageViewController? {
        guard pageIndex < numberOfPages else { return nil }
        if shouldFetchPage(at: pageIndex) {
            Task {
                await fetchImageURL(at: pageIndex)
            }
        }
        return ReaderPageViewController(readerViewModel: self, pageIndex: pageIndex)
    }
    func getPreviousReaderPageViewController() -> ReaderPageViewController? {
        // reverse pages since we scroll from right to left
        guard currentPage.value + 1 < numberOfPages else { return nil }
        let pageIndex = currentPage.value + 1
        
        // prefetch up to next five pages
        let prefetchTo = pageIndex + 5 > numberOfPages ? numberOfPages : pageIndex + 5
        for i in pageIndex..<prefetchTo {
            if shouldFetchPage(at: i) {
                Task {
                    await fetchImageURL(at: i)
                }
            }
        }
        return ReaderPageViewController(readerViewModel: self, pageIndex: pageIndex)
    }
    func getNextReaderPageViewController() -> ReaderPageViewController? {
        // reverse pages since we scroll from right to left
        guard currentPage.value > 0 else { return nil }
        let pageIndex = currentPage.value - 1
        
        // prefetch previous one page
        if shouldFetchPage(at: pageIndex) {
            Task {
                await fetchImageURL(at: pageIndex)
            }
        }
        return ReaderPageViewController(readerViewModel: self, pageIndex: pageIndex)
    }
    /// For ReaderPageViewController to fetch imageView
    func getImageURL(at pageIndex: Int) -> String? {
        if pageIndex >= numberOfPages { return nil }
        return pages.value[pageIndex].imageURL
    }
}

// MARK: - Private methods
extension ReaderViewModel {
    private func fetchImageURL(at pageIndex: Int) async {
        guard pageIndex <= numberOfPages, let pageURL = pages.value[pageIndex].pageURL else { return }
        switch source {
        case .senManga:
            // Only ganma needs to fetch image
            let page = await SenManga.shared.fetchChapterPage(from: pageURL, at: pageIndex)
            var updatedPages = pages.value
            updatedPages[pageIndex] = page
            pages.accept(updatedPages)
        default:
            return
        }
    }
    private func shouldFetchPage(at pageIndex: Int) -> Bool {
        guard pageIndex < numberOfPages else { return false }
        return pages.value[pageIndex].imageURL == nil
    }
    private func configureBindings() {
        chapterIndex
            .asObservable()
            .subscribe { [weak self] value in
                guard let self = self else { return }
                self.chapter.accept(self.chapters[value])
            }
            .disposed(by: disposeBag)
        chapter
            .asObservable()
            .subscribe { [weak self] _ in
                self?.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

