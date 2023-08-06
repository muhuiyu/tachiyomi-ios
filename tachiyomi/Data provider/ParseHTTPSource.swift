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
    var language: Language {
        // Should be implemented in subclass
        return .ja
    }
    
    var supportsLatest: Bool {
        // Should be implemented in subclass
        return true
    }
    
    var name: String {
        return "Should be implemented in subclass"
    }
    
    var baseURL: String {
        return "Should be implemented in subclass"
    }
    
    var popularMangaSelector: String {
        return "Should be implemented in subclass"
    }
    
    var popularMangaNextPageSelector: String {
       return "Should be implemented in subclass"
    }
    
    var mangaSearchResultSelector: String {
        return "Should be implemented in subclass"
    }
    
    var mangaSearchResultNextPageSelector: String {
       return "Should be implemented in subclass"
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
    
    internal func getPopularMangaRequest(at page: Int) -> URL? {
        // Should be implemented in subclass
        return nil
    }
    
    internal func parsePopularMangas(from html: String) -> MangaPage {
        do {
            let doc = try SwiftSoup.parse(html)
            let mangaElements = try doc.select(popularMangaSelector)
            let mangas = mangaElements.compactMap({ parsePopularManga(from: $0) })
            let nextPage = try doc.select(popularMangaNextPageSelector)
            return MangaPage(mangas: mangas, hasNextPage: !nextPage.isEmpty)
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
            let nextPage = try doc.select(mangaSearchResultNextPageSelector)
            return MangaPage(mangas: mangas, hasNextPage: !nextPage.isEmpty)
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
            return parseManga(from: contents, urlString)
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    internal func parseManga(from html: String, _ urlString: String) -> SourceManga? {
        // Should be implemented in subclass
        return nil
    }
    
    // MARK: - Get manga from url with partialManga
    func getManga(from urlString: String, _ partialSourceManga: SourceManga) async -> SourceManga? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let contents = String(data: data, encoding: .utf8) else {
                return nil
            }
            return parseManga(from: contents, partialSourceManga)
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    internal func parseManga(from html: String, _ partialSourceManga: SourceManga) -> SourceManga? {
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
