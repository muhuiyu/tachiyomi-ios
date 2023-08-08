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
        guard let manga = manga.value else { return }
        LocalStorage.shared.addToLibrary(for: manga, from: sourceID)
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

// MARK: - Download
extension MangaViewModel {
    func fetchPages(for chapter: SourceChapter) async -> [ChapterPage] {
        guard let provider = SourceRegistry.getProvider(for: sourceID) else { return [] }
        let result = await provider.getChapterPages(from: chapter)
        switch result {
        case .failure(let error):
            print("Error: ", error.localizedDescription)
            return []
        case .success(let fetchedPages):
            return fetchedPages
        }
    }
    func createDirectoryIfNeeded(for chapter: SourceChapter) {
        guard let folderPath = chapter.getLocalStoragePath() else { return }
        do {
            // Check if the directory exists, if not create it
            if !FileManager.default.fileExists(atPath: folderPath.path) {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Error", error)
        }
    }
    func canRestoreSavedChapter(for chapter: SourceChapter?) -> Bool {
        guard let chapter = chapter, let path = chapter.getLocalStoragePath() else { return false }
        
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
        return true
    }
}
