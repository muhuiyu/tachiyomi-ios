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
        guard let request = await getMangaRequest(for: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return await parseManga(from: data, urlString)
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    func getChapterList(from chapterURL: String, _ mangaURL: String) async -> [SourceChapter] {
        guard let request = await getChapterListRequest(from: chapterURL) else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return parseChapterList(from: data, chapterURL, mangaURL)
        } catch {
            print("An error occurred: \(error)")
            return []
        }
    }
    func parseChapterList(from data: Data, _ chapterURL: String, _ mangaURL: String) -> [SourceChapter] {
        fatalError("Not implemented")
    }
    func getChapterListRequest(from urlString: String) async -> URLRequest? {
        fatalError("Not implemented")
    }
    func searchMangas(for query: String, at page: Int) async -> MangaPage {
        fatalError("Not implemented")
    }
    func getChapterPages(from chapter: SourceChapter) async -> Result<[ChapterPage], Error> {
        guard let request = await getChapterPagesRequest(from: chapter) else { return .failure(SourceError.noPageFound) }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let pages = await parseChapterPages(from: data, chapter.url, chapter.mangaURL)
            return .success(pages)
        } catch {
            print("An error occurred: \(error)")
            return .failure(SourceError.noPageFound)
        }
    }
    func parseChapterPages(from data: Data, _ chapterURL: String, _ mangaURL: String) async -> [ChapterPage] {
        fatalError("Not implemented")
    }
    func getChapterPagesRequest(from chapter: SourceChapter) async -> URLRequest? {
        fatalError("Not implemented")
    }
    func getPopularMangaRequest(at page: Int) -> URLRequest? {
        fatalError("Not implemented")
    }
    func parsePopularManga(from data: Data) -> [SourceManga] {
        fatalError("Not implemented")
    }
    func getSearchMangaRequest(for query: String, at page: Int) -> URLRequest? {
        fatalError("Not implemented")
    }
    func parseMangaSearchResult(from data: Data) -> MangaPage {
        fatalError("Not implemented")
    }
    func parseSearchedManga(from data: Data) -> SourceManga? {
        fatalError("Not implemented")
    }
    func getMangaRequest(for identifier: String) async -> URLRequest? {
        fatalError("Not implemented")
    }
    func parseManga(from data: Data, _ urlString: String) async -> SourceManga? {
        fatalError("Not implemented")
    }
    func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage? {
        fatalError("Not implemented")
    }
}
