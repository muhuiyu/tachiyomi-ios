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
    let chapterIndex: BehaviorRelay<Int>
    
    let chapter: BehaviorRelay<SourceChapter?> = BehaviorRelay(value: nil)
    let pages: BehaviorRelay<[ChapterPage]> = BehaviorRelay(value: [])
    let chapters: [SourceChapter]
    private let sourceID: String
    
    var currentPage = BehaviorRelay(value: 0)
    var currentPageViewControllerIndex: Int? = nil
    private(set) var shouldShowNoPageFound = false
    
    init(appCoordinator: AppCoordinator? = nil, chapters: [SourceChapter], initailChapterIndex: Int, sourceID: String) {
        self.sourceID = sourceID
        self.chapters = chapters
        self.chapterIndex = BehaviorRelay(value: initailChapterIndex)
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
    var canLoadNextChapter: Bool {
        return chapterIndex.value < chapters.count - 1
    }
}

// MARK: - Data
extension ReaderViewModel {
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
    }
    func saveCurrentSession() {
        guard let chapterURL = chapter.value?.url, let mangaURL = chapter.value?.mangaURL else { return }
        if isReadingLastPage && canLoadNextChapter {
            let nextChapterURL = chapters[chapterIndex.value+1].url
            LocalStorage.shared.clearLastReadPageNumber(for: chapterURL)    // remove page bookmark from current chapter
            LocalStorage.shared.saveLastReadPageNumber(0, for: nextChapterURL) // save next chapter instead
        } else {
            LocalStorage.shared.saveLastReadPageNumber(currentPage.value, for: chapterURL)
        }
        LocalStorage.shared.saveLastReadChapterURL(chapterURL, for: mangaURL)
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
    func getPage(at pageIndex: Int) -> ChapterPage? {
        guard pageIndex < numberOfPages else { return nil }
        return pages.value[pageIndex]
    }
}

// MARK: - Private methods
extension ReaderViewModel {
    private func reloadData() {
        // Check if chapter has been saved in app
        if willRestoreSavedChapter() { return }
        
        // If not, fetch data
        guard let chapter = chapter.value, let provider = SourceRegistry.getProvider(for: sourceID) else { return }
        
        Task {
            let result = await provider.getChapterPages(from: chapter)
            switch result {
            case .failure(let error):
                print("Error: ", error.localizedDescription)
                self.shouldShowNoPageFound = true
                pages.accept([])
            case .success(let fetchedPages):
                pages.accept(fetchedPages)
            }
            restoreLastSession()
        }
    }
    private func fetchImageURL(at pageIndex: Int) async {
        guard
            pageIndex <= numberOfPages,
            let pageURL = pages.value[pageIndex].pageURL,
            let provider = SourceRegistry.getProvider(for: sourceID)
        else { return }
        
        if let page = await provider.refetchChapterPage(from: pageURL, at: pageIndex) {
            var updatedPages = pages.value
            updatedPages[pageIndex] = page
            pages.accept(updatedPages)
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
    
    /// Check if there's images stored in the path, return yes if there's image
    private func willRestoreSavedChapter() -> Bool {
        guard let chapter = chapter.value, let path = chapter.getLocalStoragePath() else { return false }
        
        print(path)
        var isDirectory = ObjCBool(false)
        let directoryExists = FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory)
        if !directoryExists || !isDirectory.boolValue {
            return false
        }
        
        // Try to get the array of files in directory
        let files: [String]
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: path.path)
        } catch {
            print("Error while enumerating files \(path): \(error.localizedDescription)")
            return false
        }

        // Check if there are any image files
        let imageFiles = files.filter({ $0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") })
        if imageFiles.isEmpty {
            return false
        }
        // Add images to pages
        let savedPages: [ChapterPage] = imageFiles.compactMap { file in
            let imageURL = path.appendingPathComponent(file).path
            print(imageURL)
            guard let pageNumberString = file.components(separatedBy: ".").first, let pageNumber = Int(pageNumberString) else { return nil }
            return ChapterPage(pageURL: imageURL, pageNumber: pageNumber, imageURL: imageURL)
        }.sorted(by: { $0.pageNumber < $1.pageNumber })
        pages.accept(savedPages)
        return true
        
    }
}

