//
//  ParseHTTPSource.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import SwiftSoup

struct MangaPage {
    let mangas: [SourceManga]
    let hasNextPage: Bool
}

class ParseHTTPSource: SourceProtocol {
    
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
    
    // MARK: - Get popular manga
    func getPopularManga(at page: Int) async -> MangaPage {
        guard let url = getPopularMangaRequest(at: page) else {
            return MangaPage(mangas: [], hasNextPage: false)
        }
            
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let contents = String(data: data, encoding: .utf8) {
                return parsePopularMangas(from: contents)
            } else {
                return MangaPage(mangas: [], hasNextPage: false)
            }
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    // MARK: - Get manga from url
    func getManga(from urlString: String) async -> SourceManga? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let contents = String(data: data, encoding: .utf8) else { return nil }
            return await parseManga(from: contents, urlString)
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    // MARK: - Search manga
    func searchMangas(for query: String, at page: Int) async -> MangaPage {
        guard let url = getSearchMangaRequest(for: query, at: page) else {
            return MangaPage(mangas: [], hasNextPage: false)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let contents = String(data: data, encoding: .utf8) {
                return parseMangaSearchResult(from: contents)
            } else {
                return MangaPage(mangas: [], hasNextPage: false)
            }
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    // MARK: - Get chapter pages
    func getChapterPages(from chapter: SourceChapter) async -> Result<[ChapterPage], Error> {
        return await getChapterPages(from: chapter.url)
    }

    var popularMangaSelector: String {
        fatalError("Not implemented")
    }
    
    var popularMangaNextPageSelector: String? {
        fatalError("Not implemented")
    }
    
    // TODO: - Add latest manga
    var latestMangaSelector: String? {
        fatalError("Not implemented")
    }
    
    var mangaSearchResultSelector: String {
        fatalError("Not implemented")
    }
    
    var chapterListSelector: String? {
        fatalError("Not implemented")
    }
    
    var mangaSearchResultNextPageSelector: String? {
        fatalError("Not implemented")
    }
    
    var mangaDetailsInfoSelector: String? {
        fatalError("Not implemented")
    }

    func getPopularMangaRequest(at page: Int) -> URL? {
        fatalError("Not implemented")
    }
    
    func parsePopularMangas(from html: String) -> MangaPage {
        do {
            let doc = try SwiftSoup.parse(html)
            let mangaElements = try doc.select(popularMangaSelector)
            let mangas = mangaElements.compactMap({ parsePopularManga(from: $0) })
            
            if let nextPageSelector = popularMangaNextPageSelector {
                let nextPage = try doc.select(nextPageSelector)
                return MangaPage(mangas: mangas, hasNextPage: !nextPage.isEmpty)
            } else {
                return MangaPage(mangas: mangas, hasNextPage: false)
            }
            
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    func parsePopularManga(from element: Element) -> SourceManga? {
        fatalError("Not implemented")
    }
    
    
    func getSearchMangaRequest(for query: String, at page: Int) -> URL? {
        fatalError("Not implemented")
    }
    
    func parseMangaSearchResult(from html: String) -> MangaPage {
        do {
            let doc = try SwiftSoup.parse(html)
            let mangaElements = try doc.select(mangaSearchResultSelector)
            let mangas = mangaElements.compactMap({ parseSearchedManga(from: $0) })
            
            if let nextPageSelector = mangaSearchResultNextPageSelector {
                let nextPage = try doc.select(nextPageSelector)
                return MangaPage(mangas: mangas, hasNextPage: !nextPage.isEmpty)
            } else {
                return MangaPage(mangas: mangas, hasNextPage: false)
            }
            
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    func parseSearchedManga(from element: Element) -> SourceManga? {
        fatalError("Not implemented")
    }
    
    func parseManga(from html: String, _ urlString: String) async -> SourceManga? {
        fatalError("Not implemented")
    }
    
    func getChapterPages(from urlString: String) async -> Result<[ChapterPage], Error> {
        guard let url = URL(string: urlString) else { return .failure(SourceError.noPageFound) }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let contents = String(data: data, encoding: .utf8) else {
                return .failure(SourceError.noPageFound)
            }
            return await parseChapterPages(from: contents, chapterURL: urlString)
        } catch {
            print("An error occurred: \(error)")
            return .failure(error)
        }
    }
    
    func parseChapterPages(from html: String, chapterURL: String) async -> Result<[ChapterPage], Error> {
        fatalError("Not implemented")
    }
    
    func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage? {
        return nil
    }
}

extension ParseHTTPSource {
    static func initURL(from urlString: String, headers: [String: String]) -> URL? {
        guard
            let url = URL(string: urlString),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return nil }
        
        headers.forEach { (key, value) in
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        return urlComponents.url
    }
}
