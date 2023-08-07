//
//  SenManga.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import SwiftSoup

class SenManga: ParsedHTTPSource {
    static let id = "senManga"
    override var sourceID: String { return SenManga.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "SenManga" }
    override var logo: String { return "sen-manga-logo" }
    override var baseURL: String { return "https://raw.senmanga.com" }
    override var isDateInReversed: Bool { return true }
    
    override var popularMangaSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "div.mng",
                                 link: nil,
                                 title: nil,
                                 image: nil,
                                 nextPage: "ul.pagination a[rel=next]")
    }
    
    override var mangaSearchResultSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "div.mng",
                                 link: nil,
                                 title: nil,
                                 image: nil,
                                 nextPage: "ul.pagination a[rel=next]")
    }
    
    override var chapterListSelector: ParseHTTPSelector? {
        return ParseHTTPSelector(main: "ul.chapter-list")
    }
    
    // MARK: - getPopularManga
    override internal func getPopularMangaRequest(at page: Int) -> URL? {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = [ URLQueryItem(name: "page", value: String(page)) ]
        return urlComponents?.url
    }
    
    override internal func parsePopularManga(from element: Element) -> SourceManga? {
        do {
            let urlString = try element.select("a").attr("href")
            guard let url = URL(string: urlString) else { return nil }
            let title = try element.select("h4.text-truncate").text()
            let thumbnailURLString = try element.select(".cover img").attr("src")
            print("parsed", title, urlString, thumbnailURLString)
            guard !title.isEmpty && !thumbnailURLString.isEmpty && thumbnailURLString != defaultImageURL else { return nil }
            return SourceManga(url: url.absoluteString, title: title, thumbnailURL: thumbnailURLString, sourceID: sourceID)
        } catch {
            return nil
        }
    }
    
    // MARK: - getSearchMangas
    override func getSearchMangaRequest(for query: String, at page: Int) -> URL? {
        var urlComponents = URLComponents(string: baseURL + "/search")
        urlComponents?.queryItems = [
            URLQueryItem(name: "s", value: query),
            URLQueryItem(name: "page", value: String(page))
        ]
        return urlComponents?.url
    }
    
    override func parseSearchedManga(from element: Element) -> SourceManga? {
        do {
            let link = try element.select("a")
            let title = try link.text()
            let urlString = try link.attr("href")
            guard let url = URL(string: urlString) else { return nil }
            let thumbnailURLString = try element.select("img").attr("data-src")
            print("parsed", title, urlString)
            guard !title.isEmpty && !thumbnailURLString.isEmpty && thumbnailURLString != defaultImageURL else { return nil }
            return SourceManga(url: url.absoluteString, title: title, thumbnailURL: thumbnailURLString, sourceID: sourceID)
        } catch {
            return nil
        }
    }
    
    // MARK: - parseManga
    override func parseManga(from html: String, _ urlString: String) async -> SourceManga? {
        do {
            let doc = try SwiftSoup.parse(html)
            var updatedManga = SourceManga(url: urlString,
                                           title: try doc.select("h1.series").text(),
                                           author: try doc.select("h1.series").text(),
                                           description: try doc.select("div.summary").text(),
                                           thumbnailURL: try doc.select("div.cover").select("img").attr("src"),
                                           sourceID: sourceID)
    
            let info = try doc.select("div")
                .filter({ $0.hasClass("items") })
            
            for eachInfo in info {
                let type = try eachInfo.select("strong").text()
                switch type.lowercased() {
                case "genres":
                    updatedManga.genres = try eachInfo.select("a").eachText()
                case "author":
                    updatedManga.author = try eachInfo.text()
                case "status":
                    let statusRawValue = try eachInfo.text()
                    if let newStatus = SourceManga.Status(rawValue: statusRawValue.lowercased()) {
                        updatedManga.status = newStatus
                    }
                default:
                    break
                }
            }
            updatedManga.chapters = await getChapterList(from: doc, urlString)
            return updatedManga
        } catch {
            return nil
        }
    }
    
    override func getChapterList(from element: Element, _ urlString: String) async -> [SourceChapter] {
        do {
            if let chapterListSelector = chapterListSelector?.main {
                let chapters = try element.select(chapterListSelector).select("li")
                    .map { chapter in
                        let url = try chapter.select("a").first?.attr("href") ?? ""
                        let name = try chapter.select("a").first?.text() ?? ""
                        let time = try chapter.select("time[datetime]").text()
                        
                        let numberRegex = Regex(/\d+(\.\d+)?/)
                        let chapterNumber = name.firstMatch(of: numberRegex)?.0 ?? "1"
                        return SourceChapter(url: url, name: name, uploadedDate: time, chapterNumber: String(chapterNumber), mangaURL: urlString)
                    }
                return isDateInReversed ? chapters.reversed() : chapters
            }
            return []
        } catch {
            return []
        }
    }

    // MARK: - parseChapterPages
    override internal func parseChapterPages(from html: String, chapterURL: String) async -> Result<[ChapterPage], Error> {
        do {
            let doc = try SwiftSoup.parse(html)
            guard
                let pageIndexString = try doc.select("select.page-list").select("option").first?.text(),
                let numberOfPages = extractPageNumber(from: pageIndexString)
            else {
                // No pages found. Return default 404 page
                return .failure(SourceError.noPageFound)
            }
            
            var pages = [ChapterPage]()
            
            let numberOfPrefetchedItems = numberOfPages > 5 ? 5 : numberOfPages
            
            // Sen Manga has one extra logo page at the end of each chapter, so we remove the last page
            for i in 1..<numberOfPages {
                let pageURL = chapterURL + "/\(i)"
                // prefetch first 5 pages and add empty pages to the rest
                if i <= numberOfPrefetchedItems {
                    if let page = await refetchChapterPage(from: pageURL, at: i) {
                        pages.append(page)
                    }
                } else {
                    pages.append(ChapterPage(pageURL: pageURL, pageNumber: i))
                }
            }
            return .success(pages)
            
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - fetchChapterPage
    override func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage? {
        let imageURL = await fetchImageURL(from: pageURL)
        guard var imageURL = imageURL else { return nil }
        
        // Some pages do not include https:
        if imageURL.starts(with: "//") {
            imageURL = "https:" + imageURL
        }
        
        // url contains spaces that need to be percentage encoding
        imageURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        print("fetched image", imageURL)
        return ChapterPage(pageURL: pageURL, pageNumber: pageNumber, imageURL: imageURL)
    }
    
    private func fetchImageURL(from urlString: String) async -> String? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else { return nil }
            
            let doc = try SwiftSoup.parse(html)
            return try doc.select("img.picture").attr("src")
            
        } catch {
            // handle error
            print("Error on fetching data: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func extractPageNumber(from string: String) -> Int? {
        let regex = try? NSRegularExpression(pattern: "\\/ \\d+$", options: [])
        let range = NSMakeRange(0, string.utf16.count)

        if let match = regex?.firstMatch(in: string, options: [], range: range) {
            let range = match.range(at: 0)
            if let swiftRange = Range(range, in: string) {
                let numberString = string[swiftRange].trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespaces)
                return Int(numberString)
            }
        }
        return nil
    }
}

// MARK: - Private properties
extension SenManga {
    private var defaultImageURL: String { "https://raw.senmanga.com/img/default.png" }
}

