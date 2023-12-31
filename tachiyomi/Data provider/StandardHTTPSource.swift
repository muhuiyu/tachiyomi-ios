//
//  StandardHTTPSource.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import UIKit
import SwiftSoup

class StandardHTTPSource: ParsedHTTPSource {
    var mangaDetailsInfoSelector: ParseHTTPSelector? {
        return ParseHTTPSelector(main: "section.series-information div.series-header",
                                 link: nil,
                                 title: "h1.series-header-title",
                                 image: [ "div.series-header-image-wrapper img", "data-src" ],
                                 nextPage: nil,
                                 author: "h2.series-header-author",
                                 description: "p.series-header-description")
    }
    override var chapterListSelector: ParseHTTPSelector? {
        return ParseHTTPSelector(main: "li.episode", link: nil, title: nil, image: nil, nextPage: nil)
    }
    
    override var isDateInReversed: Bool { return true }
    
    override internal func parsePopularManga(from element: Element) -> SourceManga? {
        do {
            guard let linkSelector = popularMangaSelector.link, let titleSelector = popularMangaSelector.title, let thumbnailSelector = popularMangaSelector.image else { return nil }
            
            let urlString = try element.select(linkSelector).attr("href")
            guard let url = URL(string: urlString) else { return nil }
            let title = try element.select(titleSelector).text()
            let thumbnailURLString = try element.select(thumbnailSelector[0]).attr(thumbnailSelector[1])
            print("parsed", title, urlString, thumbnailURLString)
            guard !title.isEmpty && !thumbnailURLString.isEmpty else { return nil }
            return SourceManga(url: url.absoluteString, title: title, thumbnailURL: thumbnailURLString, sourceID: sourceID)
        } catch {
            return nil
        }
    }
    
    override func getPopularMangaRequest(at page: Int) -> URL? {
        return ParsedHTTPSource.initURL(from: baseURL + "/series", headers: [
            "Origin": baseURL,
            "Referer": baseURL
        ])
    }
    
    override func getSearchMangaRequest(for query: String, at page: Int) -> URL? {
        return ParsedHTTPSource.initURL(from: baseURL + "/search", headers: [ "q": query ])
    }
    
    override func parseSearchedManga(from element: Element) -> SourceManga? {
        do {
            guard let linkSelector = mangaSearchResultSelector.link, let titleSelector = mangaSearchResultSelector.title, let thumbnailSelector = mangaSearchResultSelector.image else { return nil }
            
            let urlString = try element.select(linkSelector).attr("href")
            guard let url = URL(string: urlString) else { return nil }
            let title = try element.select(titleSelector).text()
            let thumbnailURLString = try element.select(thumbnailSelector[0]).attr(thumbnailSelector[1])
            print("parsed", title, urlString)
            guard !title.isEmpty && !thumbnailURLString.isEmpty else { return nil }
            return SourceManga(url: url.absoluteString, title: title, thumbnailURL: thumbnailURLString, sourceID: sourceID)
        } catch {
            return nil
        }
    }
    
    override func parseManga(from html: String, _ urlString: String) async -> SourceManga? {
        do {
            let doc = try SwiftSoup.parse(html)
            guard
                let infoSelector = mangaDetailsInfoSelector?.main,
                let titleSelector = mangaDetailsInfoSelector?.title,
                let authorSelector = mangaDetailsInfoSelector?.author,
                let descriptionSelector = mangaDetailsInfoSelector?.description,
                let thumbnailSelector = mangaDetailsInfoSelector?.image
            else { return nil }
            
            let infoElement = try doc.select(infoSelector)
            var updatedManga = SourceManga(url: urlString,
                                           title: try infoElement.select(titleSelector).text(),
                                           author: try infoElement.select(authorSelector).text(),
                                           description: try infoElement.select(descriptionSelector).text(),
                                           thumbnailURL: try infoElement.select(thumbnailSelector[0]).attr(thumbnailSelector[1]),
                                           sourceID: sourceID)
            
            updatedManga.chapters = await getChapterList(from: doc, urlString)
            return updatedManga
        } catch {
            return nil
        }
    }
    
    override func getChapterList(from element: Element, _ urlString: String) async -> [SourceChapter] {
        do {
            if let readableProductList = try element.select("div.js-readable-product-list").first() {
                let chapters = await parseChapters(from: readableProductList, urlString)
                return isDateInReversed ? chapters.reversed() : chapters
            }
            return []
        } catch {
            return []
        }
    }
    
    override func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage? {
        return nil
    }
    
    private func parseChapters(from element: Element, _ mangaURL: String) async -> [SourceChapter] {
        var chapters = [SourceChapter]()
        var nextURL: URL? = findLatestChapterEndpointURL(from: element, mangaURL: mangaURL)
        while let url = nextURL {
            let result = await fetchChapterList(from: url, mangaURL)
            chapters.append(contentsOf: result.chapters)
            nextURL = result.nextURL
        }
        
        return chapters
    }
    
    private struct ChapterListData: Codable {
        var nextUrl: String
        var html: String
    }
    
    private struct fetchChapterListResult {
        let isSuccess: Bool
        let chapters: [SourceChapter]
        let nextURL: URL?
    }
    
    private func fetchChapterList(from url: URL, _ mangaURL: String) async -> fetchChapterListResult {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response.http, response.isSuccess else {
                return fetchChapterListResult(isSuccess: false, chapters: [], nextURL: nil)
            }
            let base = try JSONDecoder().decode(ChapterListData.self, from: data)
            let doc = try SwiftSoup.parse(base.html)
            let chapterList = try doc.select("ul.series-episode-list " + (chapterListSelector?.main ?? ""))
                .compactMap({ parseChapter(from: $0, mangaURL) })
            
            return fetchChapterListResult(isSuccess: true,
                                          chapters: chapterList,
                                          nextURL: URL(string: base.nextUrl))
        } catch {
            print("An error occurred: \(error)")
            return fetchChapterListResult(isSuccess: false, chapters: [], nextURL: nil)
        }
    }
    
    private func parseChapter(from element: Element, _ mangaURL: String) -> SourceChapter? {
        do {
            let info = try element.select("a.series-episode-list-container").first() ?? element
            let name = try info.select("h4.series-episode-list-title").text()
            let updateDate = try info.select("span.series-episode-list-date").text()
            
            return SourceChapter(url: info.tagName() == "a" ? try info.attr("href") : mangaURL,
                                 name: name,
                                 uploadedDate: updateDate,
                                 chapterNumber: nil,
                                 mangaURL: mangaURL)
            
        } catch {
            return nil
        }
    }
    
    private struct ChapterPageResponseData: Codable {
        var readableProduct: ChapterPageReadableProductData
    }
    private struct ChapterPageReadableProductData: Codable {
        var pageStructure: ChapterPageStructure
    }
    private struct ChapterPageStructure: Codable {
        let pages: [ChapterPageData]
    }
    private struct ChapterPageData: Codable {
        let height: Int?
        let width: Int?
        let type: String
        let src: String?
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<StandardHTTPSource.ChapterPageData.CodingKeys> = try decoder.container(keyedBy: StandardHTTPSource.ChapterPageData.CodingKeys.self)
            self.height = try container.decodeIfPresent(Int.self, forKey: StandardHTTPSource.ChapterPageData.CodingKeys.height)
            self.width = try container.decodeIfPresent(Int.self, forKey: StandardHTTPSource.ChapterPageData.CodingKeys.width)
            self.type = try container.decode(String.self, forKey: StandardHTTPSource.ChapterPageData.CodingKeys.type)
            self.src = try container.decodeIfPresent(String.self, forKey: StandardHTTPSource.ChapterPageData.CodingKeys.src)
        }
    }
    
    override func parseChapterPages(from html: String, chapterURL: String) async -> Result<[ChapterPage], Error> {
        do {
            let doc = try SwiftSoup.parse(html)
            let episodeRawData = try doc.select("script#episode-json").attr("data-value")
            if let jsonData = episodeRawData.data(using: .utf8) {
                let base = try JSONDecoder().decode(ChapterPageResponseData.self, from: jsonData)
                let pages = base.readableProduct.pageStructure.pages.filter({ $0.type == "main" }).enumerated().map({ element in
                    print(element.element)
                    let width: Int = element.element.width ?? 822
                    let height: Int = element.element.height ?? 1200
                    let imageURL = ParsedHTTPSource.initURL(from: element.element.src ?? "", headers: [
                        "width": String(width),
                        "height": String(height),
                    ])?.absoluteString
                    return ChapterPage(pageURL: imageURL,
                                       pageNumber: element.offset,
                                       imageURL: imageURL,
                                       width: CGFloat(width),
                                       height: CGFloat(height))
                })
                return .success(pages)
            }
            return .failure(SourceError.generic)
        } catch {
            return .failure(SourceError.contentNotAvailable)
        }
    }
    
    // MARK: - Parse chapters
    private func findLatestChapterEndpointURL(from element: Element, mangaURL: String) -> URL? {
        do {
            let firstListEndpoint = try element.attr("data-first-list-endpoint")
            var latestListEndpoint = try element.attr("data-latest-list-endpoint")
            
            guard
                !firstListEndpoint.isEmpty,
                let firstListURL = URL(string: firstListEndpoint),
                var firstListComponents = URLComponents(url: firstListURL, resolvingAgainstBaseURL: true)
            else { return nil }
            
            firstListComponents.queryItems?.append(contentsOf: [
                URLQueryItem(name: "Origin", value: baseURL),
                URLQueryItem(name: "Referer", value: mangaURL),
            ])
            
            if latestListEndpoint.isEmpty {
                return firstListComponents.url
            }
            
            // compare to find which one is earlier
            guard
                let firstListURL = URL(string: firstListEndpoint),
                var firstListComponents = URLComponents(url: firstListURL, resolvingAgainstBaseURL: true),
                let latestListURL = URL(string: latestListEndpoint),
                let latestListComponents = URLComponents(url: latestListURL, resolvingAgainstBaseURL: true)
            else { return nil }
            
            let firstNumberSince = Int((firstListComponents.queryItems?.first(where: { $0.name == "number_since" })?.value ?? "")) ?? 0
            let secondNumberSince = Int((latestListComponents.queryItems?.first(where: { $0.name == "number_since" })?.value ?? "")) ?? 0
            let updatedNumberSince = max(firstNumberSince, secondNumberSince)
            
            firstListComponents.queryItems?.append(URLQueryItem(name: "number_since", value: String(updatedNumberSince)))
            return firstListComponents.url
            
        } catch {
            return nil
        }
    }
}

extension URLResponse {
    /// Returns casted `HTTPURLResponse`
    var http: HTTPURLResponse? {
        return self as? HTTPURLResponse
    }
}

extension HTTPURLResponse {
    /// Returns `true` if `statusCode` is in range 200...299.
    /// Otherwise `false`.
    var isSuccess: Bool {
        return 200 ... 299 ~= statusCode
    }
}
