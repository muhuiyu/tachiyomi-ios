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
    }
    private func getSavedMangas() -> [LibraryManga] {
        guard let data = UserDefaults.standard.data(forKey: LocalStorage.libraryMangaURLsKey),
              let entries = try? JSONDecoder().decode([LibraryManga].self, from: data) else { return [] }
        return entries
    }
    func getNumberOfLibraryMangas() -> Int {
        return getSavedMangas().count
    }
    func getLibraryMangas() async -> [SourceManga] {
        var mangas = [SourceManga]()
        for entry in getSavedMangas() {
            // fetch mangas
            if let provider = SourceRegistry.getProvider(for: entry.sourceID) {
                if let manga = await provider.getManga(from: entry.mangaURL) {
                    mangas.append(manga)
                }
            }
        }
        return mangas
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
    func addToLibrary(for mangaURL: String, from sourceID: String) {
        var mangas = getSavedMangas()
        mangas.insert(LibraryManga(sourceID: sourceID, mangaURL: mangaURL), at: 0)
        
        if let encoded = try? JSONEncoder().encode(mangas) {
            UserDefaults.standard.set(encoded, forKey: LocalStorage.libraryMangaURLsKey)
        }
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
