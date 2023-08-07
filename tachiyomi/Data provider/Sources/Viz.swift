//
//  Viz.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/7/23.
//

import UIKit
import SwiftSoup
import Kingfisher

class Viz: ParsedHTTPSource {
    override var language: Language { return .en }
    override var supportsLatest: Bool { return true }
    override var name: String { return "Viz" }
    override var logo: String { return "viz-shonen-jump-logo" }
    override var baseURL: String { return "https://www.viz.com" }
    override var isDateInReversed: Bool { return true }

    override var popularMangaSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "section.section_chapters div.o_sort_container div.o_sortable > a.o_chapters-link",
                                 link: nil,
                                 title: nil,
                                 image: nil,
                                 nextPage: nil)
    }
    
    override var mangaSearchResultSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "div.mng",
                                 link: nil,
                                 title: nil,
                                 image: nil,
                                 nextPage: "ul.pagination a[rel=next]")
    }
    
    override var chapterListSelector: ParseHTTPSelector? {
        return ParseHTTPSelector(main: "section.section_chapters div.o_sortable > a.o_chapter-container, " + "section.section_chapters div.o_sortable div.o_chapter-vol-container tr.o_chapter a.o_chapter-container.nowrap")
    }
    
    // MARK: - Properties
    var servicePath: String {
        fatalError("Not implemented")
    }
    let USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " + "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
    
    // MARK: - getPopularManga
    override internal func getPopularMangaRequest(at page: Int) -> URL? {
        return ParsedHTTPSource.initURL(from: "\(baseURL)/read/\(servicePath)/section/free-chapters", headers: [
            "User-Agent": USER_AGENT,
            "Origin": baseURL,
            "Referer": "$baseUrl/\(servicePath)"
        ])
    }
    
    override func parsePopularMangas(from html: String, _ response: URLResponse) -> MangaPage {
        do {
            if !(response.url?.absoluteString.contains("section/free-chapters") ?? false) {
                throw SourceError.countryNotSupported
            }
            let doc = try SwiftSoup.parse(html)
            let mangaElements = try doc.select(popularMangaSelector.main)
            let mangas = mangaElements.compactMap({ parsePopularManga(from: $0) })
            return MangaPage(mangas: mangas, hasNextPage: false)
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    override internal func parsePopularManga(from element: Element) -> SourceManga? {
        do {
            let urlString = try element.attr("href")
            guard let url = URL(string: baseURL + urlString) else { return nil }
            let title = try element.select("div.pad-x-rg").text()
            let thumbnailURLString = try element.select("div.pos-r img.disp-bl").attr("data-original")
            print("parsed", title, urlString, thumbnailURLString)
            guard !title.isEmpty && !thumbnailURLString.isEmpty else { return nil }
            return SourceManga(url: url.absoluteString, title: title, thumbnailURL: thumbnailURLString, sourceID: sourceID)
        } catch {
            return nil
        }
    }
    
    // MARK: - getSearchMangas
    override func getSearchMangaRequest(for query: String, at page: Int) -> URL? {
        return getPopularMangaRequest(at: page)
    }
    
    override func parseSearchedManga(from element: Element) -> SourceManga? {
        // TODO: - Fix this
        do {
            let link = try element.select("a")
            let title = try link.text()
            let urlString = try link.attr("href")
            guard let url = URL(string: urlString) else { return nil }
            let thumbnailURLString = try element.select("img").attr("data-src")
            print("parsed", title, urlString)
            guard !title.isEmpty && !thumbnailURLString.isEmpty else { return nil }
            return SourceManga(url: url.absoluteString, title: title, thumbnailURL: thumbnailURLString, sourceID: sourceID)
        } catch {
            return nil
        }
    }
    
    // MARK: - parseManga
    override func parseManga(from html: String, _ urlString: String) async -> SourceManga? {
        do {
            let doc = try SwiftSoup.parse(html)
            let seriesIntro = try doc.select("section#series-intro")
            let author = try seriesIntro.select("div.type-rg span").text().replacingOccurrences(of: "Created by ", with: "")
            var updatedManga = SourceManga(url: urlString,
                                           title: try seriesIntro.select("h2.type-lg").text(),
                                           artist: author,
                                           author: author,
                                           description: try seriesIntro.select("div.line-solid").text(),
                                           status: .ongoing,
                                           thumbnailURL: try doc.select("section.section_chapters td a > img").attr("data-original"),
                                           sourceID: sourceID)
            
            updatedManga.chapters = await getChapterList(from: doc, urlString)
            return updatedManga
        } catch {
            return nil
        }
    }
    
    override func getChapterList(from element: Element, _ urlString: String) async -> [SourceChapter] {
        do {
            if let chapterListSelector = chapterListSelector?.main {
                let chapters: [SourceChapter] = try element.select(chapterListSelector)
                    .compactMap { chapter in
                        let url = try chapter.attr("href")
                        // TODO: - Allow user to login and fetch paid content
//                        checkIfIsLoggedIn()
//                        if (loggedIn == true) {
//                            return allChapters.map { oldChapter ->
//                                oldChapter.apply {
//                                    url = url.substringAfter("'").substringBeforeLast("'") + "&locked=true"
//                                }
//                            }
//                        }
                        guard !url.starts(with: "javascript") else { return nil }
                        let content = try chapter.text()
                        guard !content.isEmpty else { return nil }
                        
                        // There are kinds of structure in VizManga:
                        // latest episodes (with time) vs. oldest episodes (without time)
                        let time = try chapter.select("div.type-bs table tr td").text()
                        let name = try time.isEmpty ? chapter.text() : chapter.select("div.line-caption table tr td.nowrap div").text()
                        let numberRegex = Regex(/\d+(\.\d+)?/)
                        let chapterNumber = name.firstMatch(of: numberRegex)?.0 ?? "1"
                        return SourceChapter(url: baseURL + url, name: name, uploadedDate: time.isEmpty ? "unknown" : time, chapterNumber: String(chapterNumber), mangaURL: urlString)
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
            guard let mangaID = chapterURL.components(separatedBy: "/").last?.components(separatedBy: "?").first else {
                return .failure(SourceError.contentNotAvailable)
            }
            // Get number of pages
            guard let pagesString = try doc.select("div#reader_button script").html()
                .components(separatedBy: "\n") // Or "\r\n" or "\r"
                .first(where: { $0.contains("pages") }) else {
                return .failure(SourceError.contentNotAvailable)
            }
            let pagesValue = pagesString
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "pages=", with: "")
                .replacingOccurrences(of: ";", with: "")
                                        
            guard let numberOfPages = Int(pagesValue) else { return .failure(SourceError.contentNotAvailable) }
            
            let pages = (0..<numberOfPages).map { page in
                let imageURL = ParsedHTTPSource.initURL(from: "\(baseURL)/manga/get_manga_url",
                                                        headers: [
                                                            "device_id": "3",
                                                            "manga_id": mangaID,
                                                            "pages": String(page)
                                                        ])
//                print(imageURL?.absoluteString)
                
                
                let modifier = AnyModifier { request in
                    var r = request
                    r.setValue("false", forHTTPHeaderField: "X-Client-Login")
                    r.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
                    r.setValue("application/json, text/javascript, */*; q=0.01", forHTTPHeaderField: "Accept")
                    return r
                }
                let url = "https://www.viz.com/manga/get_manga_url?device_id=3&manga_id\(mangaID)&pages=\(page)"
                return ChapterPage(pageURL: url, pageNumber: page, imageURL: url, modifier: modifier)
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

