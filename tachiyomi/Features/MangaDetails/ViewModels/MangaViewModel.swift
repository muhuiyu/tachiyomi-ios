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
    
    let lastReadChapterIndex: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    
    init(appCoordinator: AppCoordinator? = nil, source: Source) {
        self.source = source
        super.init(appCoordinator: appCoordinator)
    }
}

extension MangaViewModel {
    var firstChapterIndex: Int {
        return manga.value?.chapters.count ?? 0
    }
    var lastReadChapterName: String? {
        if let index = lastReadChapterIndex.value {
            return manga.value?.chapters[index].name
        }
        return nil
    }
    func reloadData() {
        guard let url = manga.value?.url else { return }
        isLoading.accept(true)
        Task {
            switch source {
            case .senManga:
                let updatedManga = await SenManga.shared.getManga(from: url)
                self.manga.accept(updatedManga)
                isLoading.accept(false)
            case .ganma:
                let updatedManga = await Ganma.shared.getManga(from: url)
                self.manga.accept(updatedManga)
                isLoading.accept(false)
            case .shonenJumpPlus:
                if let source = LocalStorage.shared.standardSources[.shonenJumpPlus] {
                    let updatedManga = await source.getManga(from: url)
                    self.manga.accept(updatedManga)
                    isLoading.accept(false)
                } else {
                    self.manga.accept(nil)
                    isLoading.accept(false)
                }
            }
        }
    }
    func addToLibrary() {
        guard let mangaURL = manga.value?.url else { return }
        LocalStorage.shared.addToLibrary(for: mangaURL)
    }
    func getChapter(at chapterIndex: Int) -> SourceChapter? {
        return manga.value?.chapters[chapterIndex]
    }
    func restoreLastReadChapter() {
        guard let mangaURL = manga.value?.url else { return }
        if let lastReadChapterURL = LocalStorage.shared.getLastReadChapterURL(for: mangaURL),
           let lastReadIndex = manga.value?.chapters.firstIndex(where: { $0.url == lastReadChapterURL }) {
            lastReadChapterIndex.accept(lastReadIndex)
        }
    }
}
