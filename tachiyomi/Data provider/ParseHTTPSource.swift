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
    var source: Source
    
    var shouldFetchChapterAsynchronously: Bool { return true }
    
    init(source: Source) {
        self.source = source
    }
    
    // MARK: - Basic information
    var language: Language {
        return source.language
    }
    
    var supportsLatest: Bool {
        return source.filters.contains(.latest)
    }
    
    var name: String {
        return source.name
    }
    
    var baseURL: String {
        return source.baseURL
    }
    
    var popularMangaSelector: String {
        return "Should be implemented in subclass"
    }
    
    var popularMangaNextPageSelector: String? { return nil }
    
    // TODO: - Add latest manga
    var latestMangaSelector: String? {
        return "Should be implemented in subclass"
    }
    
    var mangaSearchResultSelector: String {
        return "Should be implemented in subclass"
    }
    
    var chapterListSelector: String? {
        return "Should be implemented in subclass"
    }
    
    var mangaSearchResultNextPageSelector: String? { return nil }
    
    var mangaDetailsInfoSelector: String? { return nil }
    
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
    
    internal func getPopularMangaRequest(at page: Int) -> URL? { return nil }
    
    internal func parsePopularMangas(from html: String) -> MangaPage {
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
    
    internal func parsePopularManga(from element: Element) -> SourceManga? {
        // Should be implemented in subclass
        return nil
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
    
    internal func getSearchMangaRequest(for query: String, at page: Int) -> URL? {
        // Should be implemented in subclass
        return nil
    }
    
    internal func parseMangaSearchResult(from html: String) -> MangaPage {
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
    
    internal func parseSearchedManga(from element: Element) -> SourceManga? {
        // Should be implemented in subclass
        return nil
    }
    
    // MARK: - Get manga from url
    func getManga(from urlString: String) async -> SourceManga? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let contents = String(data: data, encoding: .utf8) else {
                return nil
            }
            if shouldFetchChapterAsynchronously {
                return await parseMangaAsynchronously(from: contents, urlString)
            } else {
                return parseManga(from: contents, urlString)
            }
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    internal func parseManga(from html: String, _ urlString: String) -> SourceManga? {
        // Should be implemented in subclass
        return nil
    }
    
    internal func parseMangaAsynchronously(from html: String, _ urlString: String) async -> SourceManga? {
        // Should be implemented in subclass
        return nil
    }
    
    // MARK: - Get chapter pages
    func getChapterPages(from urlString: String) async -> Result<[ChapterPage], Error> {
        guard let url = URL(string: urlString) else { return .failure(ParseHTTPSourceError.noPageFound) }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let contents = String(data: data, encoding: .utf8) else {
                return .failure(ParseHTTPSourceError.noPageFound)
            }
            return await parseChapterPages(from: contents, chapterURL: urlString)
        } catch {
            print("An error occurred: \(error)")
            return .failure(error)
        }
    }
    
    internal func parseChapterPages(from html: String, chapterURL: String) async -> Result<[ChapterPage], Error> {
        // Should be implemented in subclass
        return .failure(ParseHTTPSourceError.noPageFound)
    }
}


// MARK: - ParseHTTPSourceError
enum ParseHTTPSourceError: Error {
    case noPageFound
    case generic
}
