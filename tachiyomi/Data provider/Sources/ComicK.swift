//
//  ComicK.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/7/23.
//

import Foundation
import SwiftSoup

class ComicK: ConfigurableSource {
    static let pictureBaseURL = "https://meo.comick.pictures"
    private let homeBaseURL = "https://comick.app"
    
    override var sourceID: String {
        fatalError("Not implemented")
    }
    override var language: Language { return .en }
    override var supportsLatest: Bool { return true }
    override var name: String { return "ComicK" }
    override var logo: String { return "comick-logo" }
    override var baseURL: String { return "https://api.comick.app" }
    override var isDateInReversed: Bool { return false }
    
    private var token: String? = nil
    private let tokenTag = "$TOKEN"
    private var numberOfGetTokenRetry = 0
    
    // MARK: - Token
    private func getToken() async {
        guard let url = URL(string: homeBaseURL + "/home") else { return }
        numberOfGetTokenRetry += 1
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let contents = String(data: data, encoding: .utf8) {
                parseToken(from: contents)
            } else {
                token = nil
            }
        } catch {
            print("An error occurred: \(error)")
            token = nil
        }
    }
    
    private func parseToken(from html: String) {
        // Examples:
        // https://static.comick.app/_next/static/xImEFSRNtcUckw3c6U9KJ/_buildManifest.js
        do {
            let doc = try SwiftSoup.parse(html)
            let idScript = try doc.select("script").map({ try $0.attr("src") }).first(where: { $0.hasSuffix("/_buildManifest.js") })
            if let idScript = idScript, let range = idScript.range(of: "(?<=static/)[^/]+", options: .regularExpression) {
                token = String(idScript[range])
                print("Retrieved token", token)
                numberOfGetTokenRetry = 0
            }
        } catch {
            print("An error occurred: \(error)")
            token = nil
        }
    }
    
    // MARK: - Popular manga
    override func getPopularManga(at page: Int) async -> MangaPage {
        guard let request = getPopularMangaRequest(at: page) else {
            return MangaPage(mangas: [], hasNextPage: false)
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let mangas = parsePopularManga(from: data)
            // ComicK doesn't have next page
            return MangaPage(mangas: mangas, hasNextPage: false)
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    override func getPopularMangaRequest(at page: Int) -> URLRequest? {
        guard let url = URL(string: "\(baseURL)/top") else { return nil }
        var request = URLRequest(url: url)
        request.addValue(baseURL, forHTTPHeaderField: "Origin")
        request.addValue(baseURL, forHTTPHeaderField: "Referer")
        return request
    }
    
    override func parsePopularManga(from data: Data) -> [SourceManga] {
        do {
            let base = try JSONDecoder().decode(ComicKPopularMangasData.self, from: data)
            return base.rank.compactMap({ SourceManga(from: $0, url: getMangaURL(for: $0.slug), sourceID: sourceID) })
        } catch {
            print("Error in parsePopularManga: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Search manga
    override func getSearchMangaRequest(for query: String, at page: Int) -> URLRequest? {
        // Example:
        // https://api.comick.app/v1.0/search?q=hachimitsu-ni-hatsuko&t=true
        guard let url = URL(string: "\(baseURL)/v1.0/search") else { return nil }
        var request = URLRequest(url: url)
        request.addValue(query, forHTTPHeaderField: "q")
        request.addValue("true", forHTTPHeaderField: "t")
        return request
    }
    
    override func parseSearchedManga(from data: Data) -> SourceManga? {
        // TODO: -
        return nil
    }

    // MARK: - Get manga
    override func getMangaRequest(for urlString: String) async -> URLRequest? {
        // Example:
        // https://comick.app/_next/data/$TOKEN/comic/00-jujutsu-kaisen.json
        guard let url = URL(string: await convertURL(from: urlString)) else { return nil }
        return URLRequest(url: url)
    }

    override func parseManga(from data: Data, _ urlString: String) async -> SourceManga? {
        do {
            let base = try JSONDecoder().decode(ComicKMangaData.self, from: data)
            var updatedManga = SourceManga(from: base.pageProps, url: getMangaURL(for: base.pageProps.metadata.slug), sourceID: sourceID)
            // must support target language
            if base.pageProps.languageList.contains(language.rawValue) {
                updatedManga.chapters = await getChapterList(
                    from: "\(baseURL)/comic/\(base.pageProps.metadata.hid)/chapters?lang=\(language.rawValue)", urlString)
            }
            return updatedManga
        } catch {
            print("Error in parseManga: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Chapter List
    override func parseChapterList(from data: Data, _ chapterURL: String, _ mangaURL: String) -> [SourceChapter] {
        do {
            let base = try JSONDecoder().decode(ComicKChapterListData.self, from: data)
            print("fetched", base.chapters.count, "chapters")
            let chapters: [SourceChapter] = base.chapters.compactMap { chapter in
                guard let number = chapter.number else { return nil }
                let name = chapter.name != nil ? " - \(chapter.name!)" : ""
                return SourceChapter(url: chapterURL,
                                     name: "chapter \(number)\(name)",
                                     uploadedDate: chapter.updatedAt,
                                     chapterNumber: chapter.number,
                                     mangaURL: mangaURL,
                                     comicKChapter: chapter)
            }
            return cleanData(chapters)
            
        } catch {
            print("Error in parseChapterList: \(error.localizedDescription)")
            return []
        }
    }
    
    private func cleanData(_ chapters: [SourceChapter]) -> [SourceChapter] {
        // Remove duplicated chapter numbers
        var uniqueChaptersDict = [String: SourceChapter]()
        for chapter in chapters {
            if let chapterNumber = chapter.chapterNumber {
                if let existingChapter = uniqueChaptersDict[chapterNumber] {
                    if existingChapter.name.isEmpty && !chapter.name.isEmpty {
                        uniqueChaptersDict[chapterNumber] = chapter
                    }
                } else {
                    uniqueChaptersDict[chapterNumber] = chapter
                }
            }
        }
        return Array(uniqueChaptersDict.values.sorted(by: { Double($0.chapterNumber ?? "") ?? 0 < Double($1.chapterNumber ?? "") ?? 0 }))
    }
    
    override func getChapterListRequest(from urlString: String) async -> URLRequest? {
        // Example:
        // https://api.comick.app/comic/TA22I5O7/chapters?lang=en
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }

    // MARK: - Chapter Pages
    override func getChapterPagesRequest(from chapter: SourceChapter) async -> URLRequest? {
        // Example:
        // https://comick.app/_next/data/$TOKEN/comic/00-jujutsu-kaisen/TqsSaVdf-chapter-229-en.json
        // https://comick.app/_next/data/xImEFSRNtcUckw3c6U9KJ/comic/00-jujutsu-kaisen/1lRpoFiB-chapter-230-en.json
        guard let kChapter = chapter.comicKChapter else { return nil }
        let urlString = chapter.mangaURL.replacingOccurrences(of: ".json",
                                                              with: "/\(kChapter.getChapterQuery()).json")
        guard let url = URL(string: await convertURL(from: urlString)) else { return nil }
        return URLRequest(url: url)
    }
    
    override func parseChapterPages(from data: Data, _ chapterURL: String, _ mangaURL: String) async -> [ChapterPage] {
        do {
            let base = try JSONDecoder().decode(ComicKChapterDetailsData.self, from: data)
            guard let pages = base.pageProps.chapter.pages else { return [] }
            return pages.enumerated().map({
                ChapterPage(
                    pageURL: "\(ComicK.pictureBaseURL)/\($0.element.b2key)",
                    pageNumber: $0.offset,
                    imageURL: "\(ComicK.pictureBaseURL)/\($0.element.b2key)"
                )
            })
        } catch {
            print("Error in parseChapterPages: \(error.localizedDescription)")
            return []
        }
    }

    override func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage? {
        return nil
    }
}

// MARK: - Private Methods
extension ComicK {
    private func getMangaURL(for alias: String) -> String {
        return "\(homeBaseURL)/_next/data/\(tokenTag)/comic/\(alias).json"
    }
    private func convertURL(from urlString: String) async -> String {
        if let token = token {
            return urlString.replacingOccurrences(of: tokenTag, with: token)
        }
        if numberOfGetTokenRetry > 3 {
            print("Error: reached maximum number of token retry")
            return ""
        }
        await getToken()
        return await convertURL(from: urlString)
    }
}


// MARK: - Data models
struct ComicKPopularMangasData: Decodable {
    var rank: [ComicMangaOverviewData]
    var recentRank: [ComicMangaOverviewData]
    var trending: ComickTrendingMangasData
    var latestMangas: [ComicMangaOverviewData]
    var completedMangas: [ComicMangaOverviewData]
    
    enum CodingKeys: String, CodingKey {
        case rank
        case recentRank
        case trending
        case latestMangas = "news"
        case extendedLatest = "extendedNews"
        case completedMangas = "completions"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rank = try container.decode([ComicMangaOverviewData].self, forKey: .rank)
        self.recentRank = try container.decode([ComicMangaOverviewData].self, forKey: .recentRank)
        self.trending = try container.decode(ComickTrendingMangasData.self, forKey: .trending)
        let firstPartOfLatests = try container.decode([ComicMangaOverviewData].self, forKey: .latestMangas)
        let secondPartOfLatests = try container.decode([ComicMangaOverviewData].self, forKey: .extendedLatest)
        self.latestMangas = firstPartOfLatests + secondPartOfLatests
        self.completedMangas = try container.decode([ComicMangaOverviewData].self, forKey: .completedMangas)
    }
}

struct ComickTrendingMangasData: Codable {
    var sevenDays: [ComicMangaOverviewData]
    var thirtyDays: [ComicMangaOverviewData]
    var nintyDays: [ComicMangaOverviewData]
    
    enum CodingKeys: String, CodingKey {
        case sevenDays = "7"
        case thirtyDays = "30"
        case nintyDays = "90"
    }
}

struct ComicMangaOverviewData: Codable {
    let slug: String
    let title: String
    let demographic: Int?
    let contentRating: String?
    let lastChapter: Int?
    let thumbnailURLs: [ComicKFile]
    
    enum CodingKeys: String, CodingKey {
        case slug
        case title
        case demographic
        case contentRating = "content_rating"
        case lastChapter
        case thumbnailURLs = "md_covers"
    }
}
        
struct ComicKFile: Codable {
    let width: Int
    let height: Int
    let b2key: String
    
    enum CodingKeys: String, CodingKey {
        case width = "w"
        case height = "h"
        case b2key
    }
}

struct ComicKChapterListData: Codable {
    let chapters: [ComicKChapter]
    let total: Int
}

struct ComicKChapter: Codable {
    let id: Int
    let number: String?
    let name: String?
    let updatedAt: String
    let hid: String
    let language: String
    let pages: [ComicKFile]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case number = "chap"
        case name = "title"
        case updatedAt = "updated_at"
        case hid
        case language = "lang"
        case pages = "md_images"
    }
    
    func getChapterQuery() -> String {
        return "\(hid)-chapter-\(number ?? "")-\(language)"
    }
}

struct ComicKMangaData: Codable {
    let pageProps: ComicKMangaDetails
}

struct ComicKMangaDetails: Codable {
    let metadata: ComicKMangaMetadata
    let artists: [ComicKMangaItem]
    let authors: [ComicKMangaItem]
    let languageList: [String]
    let genres: [ComicKMangaItem]
    
    enum CodingKeys: String, CodingKey {
        case metadata = "comic"
        case artists
        case authors
        case languageList = "langList"
        case genres
    }
}

struct ComicKMangaItem: Codable {
    let name: String
    let slug: String
}

struct ComicKMangaMetadata: Codable {
    let id: Int
    let hid: String
    let title: String
    let country: String
    let status: Int
    let lastChapter: String
    let chapterCount: Int
    let description: String
    let slug: String
    let language: String
    let finalChapter: String?
    let thumbnailURLs: [ComicKFile]
    
    enum CodingKeys: String, CodingKey {
        case id
        case hid
        case title
        case country
        case status
        case lastChapter = "last_chapter"
        case chapterCount = "chapter_count"
        case description = "desc"
        case slug
        case language = "iso639_1"
        case finalChapter = "final_chapter"
        case thumbnailURLs = "md_covers"
    }
}

struct ComicKChapterDetailsData: Codable {
    let pageProps: ComicKChapterDetails
}

struct ComicKChapterDetails: Codable {
    let chapter: ComicKChapter
}

extension SourceManga {
    init(from data: ComicMangaOverviewData, url: String, sourceID: String) {
        self.id = UUID(from: url)
        self.url = url
        self.title = data.title
        self.alias = data.slug
        self.artist = nil
        self.author = nil
        self.description = nil
        self.genres = []
        self.status = nil
        self.thumbnailURL = ComicK.pictureBaseURL + "/" + (data.thumbnailURLs.first?.b2key ?? "")
        self.updateStrategy = nil
        self.isInitialized = true
        self.chapters = []
        self.sourceID = sourceID
    }
    init(from data: ComicKMangaDetails, url: String, sourceID: String) {
        self.id = UUID(from: url)
        self.url = url
        self.title = data.metadata.title
        self.alias = data.metadata.slug
        self.artist = data.artists.first?.name
        self.author = data.authors.first?.name
        self.description = data.metadata.description
        self.genres = data.genres.map({ $0.name })
        self.status = data.metadata.finalChapter == nil ? .ongoing : .completed
        self.thumbnailURL = ComicK.pictureBaseURL + "/" + (data.metadata.thumbnailURLs.first?.b2key ?? "")
        self.updateStrategy = nil
        self.isInitialized = true
        self.chapters = []
        self.sourceID = sourceID
    }
}
