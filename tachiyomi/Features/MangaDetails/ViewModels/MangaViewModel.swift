//
//  MangaViewModel.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxSwift
import RxRelay

class MangaViewModel: Base.ViewModel {
    let manga: BehaviorRelay<SourceManga?> = BehaviorRelay(value: nil)
    let source: Source
    let isLoading = BehaviorRelay(value: true)
    
    init(appCoordinator: AppCoordinator? = nil, source: Source) {
        self.source = source
        super.init(appCoordinator: appCoordinator)
    }
}

extension MangaViewModel {
    var firstChapterIndex: Int {
        return manga.value?.chapters.count ?? 0
    }
    func reloadData() {
        guard let manga = manga.value, let url = manga.url else { return }
        isLoading.accept(true)
        Task {
            switch source {
            case .senManga:
                let updatedManga = await SenManga.shared.getManga(from: url, manga)
                self.manga.accept(updatedManga)
                isLoading.accept(false)
            case .ganma:
                let updatedManga = await Ganma.shared.getManga(from: url)
                self.manga.accept(updatedManga)
                isLoading.accept(false)
            }
        }
    }
    func addToLibrary() {
        guard let mangaURL = manga.value?.url else { return }
        LocalStorage.shared.addToLibrary(for: mangaURL)
    }
    func getChapter(at chapterIndex: Int) -> SourceChapter? {
        return manga.value?.chapters[chapterIndex-1]
    }
}
