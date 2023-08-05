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

