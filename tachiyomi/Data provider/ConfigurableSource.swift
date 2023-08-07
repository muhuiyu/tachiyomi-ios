//
//  ConfigurableSource.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/5/23.
//

import Foundation

class ConfigurableSource: SourceProtocol {
    
    // MARK: - Basic information
    var sourceID: String {
        fatalError("Not implemented")
    }
    
    var language: Language {
        fatalError("Not implemented")
    }
    
    var supportsLatest: Bool {
        fatalError("Not implemented")
    }
    
    var name: String {
        fatalError("Not implemented")
    }
    
    var logo: String {
        fatalError("Not implemented")
    }
    
    var baseURL: String {
        fatalError("Not implemented")
    }
    
    var isDateInReversed: Bool {
        fatalError("Not implemented")
    }
    
    func getPopularManga(at page: Int) async -> MangaPage {
        fatalError("Not implemented")
    }
    
    func getManga(from urlString: String) async -> SourceManga? {
        guard let request = getMangaRequest(for: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return parseManga(from: data)
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    func searchMangas(for query: String, at page: Int) async -> MangaPage {
        // Not supported, filter from popular mangas
        let popularMangaPage = await getPopularManga(at: page)
        let filteredMangas = popularMangaPage.mangas.filter { manga in
            guard let mangaTitle = manga.title else { return false }
            for word in query.split(separator: " ") {
                if mangaTitle.contains(word) {
                    return true
                }
            }
            return false
        }
        return MangaPage(mangas: filteredMangas, hasNextPage: popularMangaPage.hasNextPage)
    }
    func getChapterPages(from chapter: SourceChapter) async -> Result<[ChapterPage], Error> {
        fatalError("Not implemented")
    }
    func getPopularMangaRequest(at page: Int) -> URLRequest? {
        fatalError("Not implemented")
    }
    func parsePopularManga(from data: Data) -> [SourceManga] {
        fatalError("Not implemented")
    }
    func getMangaRequest(for identifier: String) -> URLRequest? {
        fatalError("Not implemented")
    }
    func parseManga(from data: Data) -> SourceManga? {
        fatalError("Not implemented")
    }
    func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage? {
        fatalError("Not implemented")
    }
}
