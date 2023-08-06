//
//  Ganma.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/5/23.
//

import UIKit
import SwiftSoup

class Ganma: ConfigurableSource {
    static let shared = Ganma()
    
    override var language: Language {
        return Source.ganma.language
    }
    
    override var supportsLatest: Bool {
        return true
    }
    
    override var name: String {
        return Source.ganma.name
    }
    
    override var baseURL: String {
        return "https://ganma.jp"
    }
    
    override func getPopularManga(at page: Int) async -> MangaPage {
        guard let request = getPopularMangaRequest(at: page) else {
            return MangaPage(mangas: [], hasNextPage: false)
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let mangas = parsePopularManga(from: data)
            // Ganma doesn't have next page
            return MangaPage(mangas: mangas, hasNextPage: false)
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
    
    override func parsePopularManga(from data: Data) -> [SourceManga] {
        do {
            let base = try JSONDecoder().decode(GanmaPopularMangasData.self, from: data)
            return base.root.compactMap({ SourceManga(from: $0) })
        } catch {
            print("Error in parsePopularManga: \(error.localizedDescription)")
            return []
        }
    }
    
    func getMangaURL(for alias: String) -> String {
        return "\(baseURL)/api/1.0/magazines/web/\(alias)"
    }
    
    override func getMangaRequest(for urlString: String) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.addValue(baseURL, forHTTPHeaderField: "X-From")
        return request
    }
    
    override func parseManga(from data: Data) -> SourceManga? {
        do {
            let base = try JSONDecoder().decode(GanmaMangaDetailsData.self, from: data)
            return SourceManga(from: base.root)
        } catch {
            print("Error in parseManga: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Get chapter pages
    func getChapterPages(from chapter: GanmaMagazinePage) -> [ChapterPage] {
        return chapter.files
            .enumerated()
            .map({ ChapterPage(pageNumber: $0.offset, imageURL: "\(chapter.baseURL)\($0.element)?\(chapter.token)") })
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
    
    func toChapter(at index: Int) -> SourceChapter {
        var name = title
        if let subtitle = subtitle {
            name += "- \(subtitle)"
        }
        return SourceChapter(url: page.baseURL,
                             name: name,
                             uploadedDate: getReleaseDateString(),
                             chapterNumber: String(index+1),
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
