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
    let sourceID: String
    let isLoading = BehaviorRelay(value: true)
    
    let lastReadChapterIndex: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    
    init(appCoordinator: AppCoordinator? = nil, sourceID: String) {
        self.sourceID = sourceID
        super.init(appCoordinator: appCoordinator)
    }
}

extension MangaViewModel {
    var firstChapterIndex: Int {
//        guard let manga = manga.value else { return 0 }
//        return manga.chapters.count - 1
        return 0
    }
    var lastReadChapterName: String? {
        if let index = lastReadChapterIndex.value {
            return manga.value?.chapters[index].name
        }
        return nil
    }
    func reloadData() {
        guard let url = manga.value?.url, let provider = SourceRegistry.getProvider(for: sourceID) else { return }
        isLoading.accept(true)
        Task {
            let updatedManga = await provider.getManga(from: url)
            self.manga.accept(updatedManga)
            isLoading.accept(false)
        }
    }
    func addToLibrary() {
        guard let mangaURL = manga.value?.url else { return }
        LocalStorage.shared.addToLibrary(for: mangaURL, from: sourceID)
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
