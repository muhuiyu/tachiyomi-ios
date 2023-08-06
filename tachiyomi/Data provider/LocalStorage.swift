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
    func getLibraryMangas() async -> [SourceManga] {
        if let mangaURLs = UserDefaults.standard.object(forKey: LocalStorage.libraryMangaURLsKey) as? [String] {
            // fetch mangas
            var mangas = [SourceManga]()
            for mangaURL in mangaURLs {
                if mangaURL.contains(SenManga.shared.baseURL) {
                    if let manga = await SenManga.shared.getManga(from: mangaURL) {
                        mangas.append(manga)
                    }
                } else if mangaURL.contains(Ganma.shared.baseURL) {
                    if let manga = await Ganma.shared.getManga(from: mangaURL) {
                        mangas.append(manga)
                    }
                }
            }
            return mangas
        }
        return []
    }
    func libraryContains(_ mangaURL: String) -> Bool {
        if let mangaURLs = UserDefaults.standard.object(forKey: LocalStorage.libraryMangaURLsKey) as? [String] {
            return mangaURLs.contains(mangaURL)
        }
        return false
    }
    func setLibraryMangas(to mangaURLs: [String]) {
        UserDefaults.standard.setValue(mangaURLs, forKey: LocalStorage.libraryMangaURLsKey)
    }
    func addToLibrary(for mangaURL: String) {
        var mangaURLs = [String]()
        if let libraryMangaURLs = UserDefaults.standard.object(forKey: LocalStorage.libraryMangaURLsKey) as? [String] {
            mangaURLs += libraryMangaURLs
        }
        mangaURLs.append(mangaURL)
        UserDefaults.standard.set(mangaURLs, forKey: LocalStorage.libraryMangaURLsKey)
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
