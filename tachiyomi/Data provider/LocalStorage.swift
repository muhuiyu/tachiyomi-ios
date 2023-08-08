//
//  DataProvider.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

class LocalStorage {
    static let shared: LocalStorage = LocalStorage()
    
    // keys
    static var libraryMangaURLsKey: String { "k_library_manga_urls" }
    
    // for manga
    // mangaURL: chapterURL
    static var lastReadMangaChapterKey: String { "k_last_read_manga_chapter" }
    
    // for chapters
    // chapterURL: pageNumber
    static var lastReadChapterPageKey: String { "k_last_read_chapter_page" }
}

// MARK: - Library
extension LocalStorage {
    private struct LibraryManga: Codable {
        let sourceID: String
        let mangaURL: String
        let title: String
        let thumbnailImagePath: String
    }
    private func getSavedMangas() -> [LibraryManga] {
        guard let data = UserDefaults.standard.data(forKey: LocalStorage.libraryMangaURLsKey),
              let entries = try? JSONDecoder().decode([LibraryManga].self, from: data) else { return [] }
        return entries
    }
    func getNumberOfLibraryMangas() -> Int {
        return getSavedMangas().count
    }
    func getLibraryMangas() -> [SourceManga] {
        return getSavedMangas().map({
            SourceManga(url: $0.mangaURL, title: $0.title, thumbnailURL: $0.thumbnailImagePath, sourceID: $0.sourceID)
        })
    }
    func libraryContains(_ mangaURL: String) -> Bool {
        return getSavedMangas().contains(where: { $0.mangaURL == mangaURL })
    }
    func setLibraryMangas(to mangaURLs: [String]) {
        UserDefaults.standard.setValue(mangaURLs, forKey: LocalStorage.libraryMangaURLsKey)
    }
    func deleteMangaFromLibrary(for mangaURL: String) {
        var savedMangas = getSavedMangas()
        if !savedMangas.isEmpty {
            savedMangas.removeAll(where: { $0.mangaURL == mangaURL })
            if let encoded = try? JSONEncoder().encode(savedMangas) {
                UserDefaults.standard.setValue(encoded, forKey: LocalStorage.libraryMangaURLsKey)
            }
        }
    }
    func addToLibrary(for manga: SourceManga, from sourceID: String) {
        var mangas = getSavedMangas()
        guard let imagePath = getMangaThumbnailPath(for: manga), let mangaTitle = manga.title else { return }
        Task {
            createDirectoryIfNeeded(for: manga)
            await downloadMangaThumbnailIfNeeded(as: imagePath, for: manga.thumbnailURL)
        }
        mangas.insert(LibraryManga(sourceID: sourceID, mangaURL: manga.url, title: mangaTitle, thumbnailImagePath: imagePath.path), at: 0)
        if let encoded = try? JSONEncoder().encode(mangas) {
            UserDefaults.standard.set(encoded, forKey: LocalStorage.libraryMangaURLsKey)
        }
    }
    private func downloadMangaThumbnailIfNeeded(as path: URL, for imageURL: String?) async {
        // check if path exists
        if !FileManager.default.fileExists(atPath: path.path), let imageURL = imageURL, let url = URL(string: imageURL) {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            do {
                let (location, _) = try await session.download(from: url)
                try FileManager.default.moveItem(at: location, to: path)
            } catch {
                print(error)
            }
        }
    }
    private func createDirectoryIfNeeded(for manga: SourceManga) {
        guard let folderPath = manga.getLocalStoragePath() else { return }
        do {
            // Check if the directory exists, if not create it
            if !FileManager.default.fileExists(atPath: folderPath.path) {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Error", error)
        }
    }
    private func getMangaThumbnailPath(for manga: SourceManga) -> URL? {
        guard let fileExtension = manga.thumbnailURL?.components(separatedBy: ".").last else { return nil }
        return manga.getLocalStoragePath()?.appendingPathComponent("thumbnail." + fileExtension)
    }
}

// MARK: - Last read
extension LocalStorage {
    func getLastReadChapterURL(for mangaURL: String) -> String? {
        if let lastReadMangaChapterDictionary = UserDefaults.standard.object(forKey: LocalStorage.lastReadMangaChapterKey) as? [String: String] {
           return lastReadMangaChapterDictionary[mangaURL]
        }
        return nil
    }
    func saveLastReadChapterURL(_ chapterURL: String, for mangaURL: String) {
        var dictionary = [String: String]()
        if let lastReadMangaChapterDictionary = UserDefaults.standard.object(forKey: LocalStorage.lastReadMangaChapterKey) as? [String: String] {
           dictionary = lastReadMangaChapterDictionary
        }
        dictionary[mangaURL] = chapterURL
        UserDefaults.standard.set(dictionary, forKey: LocalStorage.lastReadMangaChapterKey)
    }
    func clearLastReadPageNumber(for chapterURL: String) {
        var dictionary = [String: Int]()
        if let lastReadChapterPageDictionary = UserDefaults.standard.object(forKey: LocalStorage.lastReadChapterPageKey) as? [String: Int] {
           dictionary = lastReadChapterPageDictionary
        }
        dictionary.removeValue(forKey: chapterURL)
        UserDefaults.standard.set(dictionary, forKey: LocalStorage.lastReadChapterPageKey)
    }
    func getLastReadPageNumber(for chapterURL: String) -> Int? {
        if let lastReadChapterPageDictionary = UserDefaults.standard.object(forKey: LocalStorage.lastReadChapterPageKey) as? [String: Int] {
           return lastReadChapterPageDictionary[chapterURL]
        }
        return nil
    }
    func saveLastReadPageNumber(_ pageNumber: Int, for chapterURL: String) {
        var dictionary = [String: Int]()
        if let lastReadChapterPageDictionary = UserDefaults.standard.object(forKey: LocalStorage.lastReadChapterPageKey) as? [String: Int] {
           dictionary = lastReadChapterPageDictionary
        }
        dictionary[chapterURL] = pageNumber
        UserDefaults.standard.set(dictionary, forKey: LocalStorage.lastReadChapterPageKey)
    }
}
