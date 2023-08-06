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
    
    let chapter: BehaviorRelay<SourceChapter?> = BehaviorRelay(value: nil)
    let pages: BehaviorRelay<[ChapterPage]> = BehaviorRelay(value: [])
    private let source: Source
    
    var currentPage = 0
    private(set) var shouldShowNoPageFound = false
    
    init(appCoordinator: AppCoordinator? = nil, source: Source) {
        self.source = source
        super.init(appCoordinator: appCoordinator)
        configureBindings()
    }
}

extension ReaderViewModel {
    private func configureBindings() {
        chapter
            .asObservable()
            .subscribe { [weak self] _ in
                self?.reloadData()
            }
            .disposed(by: disposeBag)
    }
    func reloadData() {
        guard let chapterURL = chapter.value?.url else { return }
        Task {
            switch source {
            case .senManga:
                let result = await SenManga.shared.getChapterPages(from:  chapterURL)
                switch result {
                case .failure(let error):
                    print("Error: ", error.localizedDescription)
                    self.shouldShowNoPageFound = true
                    pages.accept([])
                case .success(let fetchedPages):
                    pages.accept(fetchedPages)
                }
            case .ganma:
                guard let page = chapter.value?.ganmaPage else { return }
                let fetchedPages = Ganma.shared.getChapterPages(from: page)
                pages.accept(fetchedPages)
            }
        }
    }
    func getFirstPageImageURLString() -> String? {
        guard !pages.value.isEmpty else { return nil }
        return pages.value[0].imageURL
    }
    func getPreviousPageImageURLString() -> String? {
        // reverse pages since we scroll from right to left
        guard currentPage + 1 < pages.value.count else { return nil }
        return pages.value[currentPage + 1].imageURL
    }
    func getNextPageImageURLString() -> String? {
        // reverse pages since we scroll from right to left
        guard currentPage > 0 else { return nil }
        return pages.value[currentPage - 1].imageURL
    }
}

