//
//  Ganma.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/5/23.
//

import UIKit
import SwiftSoup

class Ganma: ConfigurableSource {
    static let id = "ganma"
    
    override var sourceID: String { return Ganma.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "ガンマ" }
    override var logo: String { return "ganma-logo" }
    override var baseURL: String { return "https://ganma.jp" }
    override var isDateInReversed: Bool { return false }
    
    override func getPopularManga(at page: Int) async -> MangaPage {
        guard let request = getPopularMangaRequest(at: page) else {
            return MangaPage(mangas: [], hasNextPage: false)
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return parsePopularMangas(from: data)
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    override func getPopularMangaRequest(at page: Int) -> URLRequest? {
        let url: URL?
        switch page {
        case 1:
            url = URL(string: "\(baseURL)/api/1.0/ranking")
        default:
            url = URL(string: "\(baseURL)/api/1.1/ranking?flag=Finish") // filter to get all finished mangas?
        }
        guard let url = url else { return nil }
        
        var request = URLRequest(url: url)
        request.addValue(baseURL, forHTTPHeaderField: "X-From")
        return request
    }
    
    override func parsePopularMangas(from data: Data) -> MangaPage {
        do {
            let base = try JSONDecoder().decode(GanmaPopularMangasData.self, from: data)
            let mangas = base.root.compactMap({ SourceManga(from: $0, url: getMangaURL(for: $0.alias)) })
            // Ganma has no next page
            return MangaPage(mangas: mangas, hasNextPage: false)
        } catch {
            print("Error in parsePopularManga: \(error.localizedDescription)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    override func getMangaRequest(for urlString: String) async -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.addValue(baseURL, forHTTPHeaderField: "X-From")
        return request
    }
    
    override func searchMangas(for query: String, at page: Int) async -> MangaPage {
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
    
    override func parseManga(from data: Data, _ urlString: String) async -> SourceManga? {
        do {
            let base = try JSONDecoder().decode(GanmaMangaDetailsData.self, from: data)
            return SourceManga(from: base.root, url: getMangaURL(for: base.root.alias))
        } catch {
            print("Error in parseManga: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func getChapterPages(from chapter: SourceChapter) async -> Result<[ChapterPage], Error> {
        guard let page = chapter.ganmaPage else { return .failure(SourceError.noPageFound)}
        let pages = page.files
            .enumerated()
            .map({ ChapterPage(pageNumber: $0.offset, imageURL: "\(page.baseURL)\($0.element)?\(page.token)") })
        return .success(pages)
    }
    
    override func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage? {
        return nil
    }
}

// MARK: - Private Methods
extension Ganma {
    private func getMangaURL(for alias: String) -> String {
        return "\(baseURL)/api/1.0/magazines/web/\(alias)"
    }
}


// MARK: - Data models
struct GanmaPopularMangasData: Codable {
    let success: Bool
    let root: [GanmaMangaOverviewRoot]
}

struct GanmaMangaOverviewRoot: Codable {
    let id: String
    let alias: String
    let title: String
    let overview: String
    let squareImage: GanmaFile
    let author: GanmaAuthor
    let heartCount: Int
    let bookmarkCount: Int
    let isGTOON: Bool
    let isNewSerial: Bool
}

struct GanmaFile: Codable {
    let url: String
    let id: String
}

struct GanmaAuthor: Codable {
    let id: String
    let profileImage: GanmaFile
    let penName: String
    let profile: String
}

struct GanmaSeries: Codable {
    let id: String
    let title: String
    let squareImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case squareImageURL = "squareImageUrl"
    }
}

struct GanmaMangaDetailsData: Codable {
    let success: Bool
    let root: GanmaMagazine
}

struct GanmaMagazine: Codable {
    let id: String
    let alias: String
    let title: String
    let description: String
    let overview: String?
    let lead: String?
    let author: GanmaAuthor
    let series: GanmaSeries
    let rectangleImage: GanmaFile
    let squareImage: GanmaFile
    let flags: GanmaMagazineFlags
    let publicLatestStoryNumber: Int
    let items: [GanmaMagazineStoryItem]
    let newestStoryInformation: GanmaMagazineNewestStoryInformation
    let release: Int
    let thumbnail: GanmaFile
    let coverImage: GanmaFile
    let storyReleaseStatus: String
}

struct GanmaMagazineFlags: Codable {
    let isSunday: Bool?
    let isMonday: Bool?
    let isTuesday: Bool?
    let isWednesday: Bool?
    let isThursday: Bool?
    let isFriday: Bool?
    let isSaturday: Bool?
    let isWeekly: Bool?
    let isEveryOtherWeek: Bool?
    let isThreeConsecutiveWeeks: Bool?
    let isMonthly: Bool?
    let isFinished: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isSunday
        case isMonday
        case isTuesday
        case isWednesday
        case isThursday
        case isFriday
        case isSaturday
        case isWeekly
        case isEveryOtherWeek
        case isThreeConsecutiveWeeks
        case isMonthly
        case isFinished = "isFinish"
    }
}

struct GanmaMagazineStoryItem: Codable {
    let id: String?
    let storyID: String?
    let title: String
    let subtitle: String?
    let releaseStart: Int
    let releaseForFree: Int?
    let kind: String
    let page: GanmaMagazinePage
    let afterwordImage: GanmaFile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case storyID = "storyId"
        case title
        case subtitle
        case releaseStart
        case releaseForFree
        case kind
        case page
        case afterwordImage
    }
    
    func toChapter(at index: Int, for mangaURL: String) -> SourceChapter {
        var name = title
        if let subtitle = subtitle {
            name += "- \(subtitle)"
        }
        return SourceChapter(url: page.baseURL,
                             name: name,
                             uploadedDate: getReleaseDateString(),
                             chapterNumber: String(index+1),
                             mangaURL: mangaURL,
                             ganmaPage: page)
    }
    
    func getReleaseDateString() -> String {
        let timestamp = releaseStart / 1000 // divide by 1000 to convert milliseconds to seconds.
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcDateString = formatter.string(from: date)
        return utcDateString
    }
}

struct GanmaMagazinePage: Codable {
    let id: String
    let baseURL: String
    let token: String
    let files: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case baseURL = "baseUrl"
        case token
        case files
    }
}

struct GanmaMagazineStoryThumbnail: Codable {
    let url: String
}

struct GanmaMagazineNewestStoryInformation: Codable {
    let release: Int
    let id: String
    let series: GanmaSeries
    let author: GanmaAuthor
    let title: String
    let subTitle: String?
}

// MARK: - Ganma data decoder
extension SourceManga {
    init(from ganmaData: GanmaMangaOverviewRoot, url: String) {
        self.id = UUID(from: url)
        self.url = url
        self.title = ganmaData.title
        self.alias = ganmaData.alias
        self.artist = nil
        self.author = ganmaData.author.penName
        self.description = ganmaData.overview
        self.genres = []
        self.status = .unknown
        self.thumbnailURL = ganmaData.squareImage.url
        self.updateStrategy = nil
        self.isInitialized = nil
        self.chapters = []
        self.sourceID = Ganma.id
    }
    init(from magazine: GanmaMagazine, url: String) {
        let mangaURL = url
        self.id = UUID(from: mangaURL)
        self.url = mangaURL
        self.title = magazine.title
        self.alias = magazine.alias
        self.author = magazine.author.penName
        self.description = magazine.description
        self.genres = []
        self.status = magazine.flags.isFinished ?? false ? .completed : .ongoing
        self.thumbnailURL = magazine.squareImage.url
        self.updateStrategy = nil
        self.isInitialized = true
        self.chapters = magazine.items.enumerated().map({ $0.element.toChapter(at: $0.offset, for: mangaURL) })
        self.sourceID = Ganma.id
    }
}
