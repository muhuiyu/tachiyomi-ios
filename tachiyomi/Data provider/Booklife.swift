//
//  Booklife.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/5/23.
//

import Foundation

class Booklife: ConfigurableSource {
    static let shared = Booklife()
    
    override var language: Language {
        return Source.booklive.language
    }
    
    override var supportsLatest: Bool {
        return true
    }
    
    override var name: String {
        return Source.booklive.name
    }
    
    override var baseURL: String {
        return "https://booklive.jp/"
    }
    
    var thumbnailBaseURL: String { "https://res.booklive.jp/" }
    
    override func getPopularManga(at page: Int) async -> MangaPage {
        guard let request = getPopularMangaRequest(at: page) else {
            return MangaPage(mangas: [], hasNextPage: false)
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let mangas = parsePopularManga(from: data)
            // only support 4 pages
            return MangaPage(mangas: mangas, hasNextPage: (page < 4))
        } catch {
            print("An error occurred: \(error)")
            return MangaPage(mangas: [], hasNextPage: false)
        }
    }
    
    override func getPopularMangaRequest(at page: Int) -> URLRequest? {
        // Free manga only (up to 4 pages for now)
        var urlString = ""
        switch page {
        case 1:
            urlString = "\(baseURL)/json/popular-no-charge"
        case 2:
            urlString = "\(baseURL)/json/mediatized-no-charge"
        case 3:
            urlString = "\(baseURL)/json/completed-no-charge"
        case 4:
            urlString = "\(baseURL)/json/tateyomi-no-charge"
        default:
            break
        }
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }
    
    override func parsePopularManga(from data: Data) -> [SourceManga] {
        do {
            let base = try JSONDecoder().decode(BooklifePopularMangasData.self, from: data)
            return base.titleList.compactMap({ SourceManga(from: $0) })
        } catch {
            print("Error in parsePopularManga: \(error.localizedDescription)")
            return []
        }
    }
    
//    func getMangaURL(for alias: String) -> String {
//        return "\(baseURL)/api/1.0/magazines/web/\(alias)"
//    }
    
    override func getMangaRequest(for urlString: String) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }

    override func parseManga(from data: Data) -> SourceManga? {
        do {
            let base = try JSONDecoder().decode(BooklifeMangaDetailsData.self, from: data)
            return SourceManga(from: base.titleList)
        } catch {
//            print("Error in parseManga: \(error.localizedDescription)")
//            return nil
        }
        return nil
    }
    
    // MARK: - Get chapter pages
//    func getChapterPages(from chapter: GanmaMagazinePage) -> [ChapterPage] {
//        return chapter.files
//            .enumerated()
//            .map({ ChapterPage(pageNumber: $0.offset, imageURL: "\(chapter.baseUrl)\($0.element)?\(chapter.token)") })
//    }
}

struct BooklifePopularMangasData: Codable {
    let titleList: [BooklifeMangaOverview]
    
    enum CodingKeys: String, CodingKey {
        case titleList = "title_list"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.titleList = try container.decode([BooklifeMangaOverview].self, forKey: .titleList)
    }
}

struct BooklifeMangaOverview: Codable {
    let categoryID: String
    let titleID: Int
    // return the first vol as volNo
    let volNo: String
    let titleVolName: String
    let authors: [BooklifeAuthor]
    let genreID: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case titleID = "title_id"
        case volNo = "vol_no"
        case titleVolName = "title_vol_name"
        case authors = "author_list_multi"
        case genreID = "genre_id"
    }
    
    func getURL() -> String {
        // use the first chapter to get all available chapters
        return "\(Booklife.shared.baseURL)json/series?title_id=\(String(titleID))&vol_no=\(volNo)&type=series_list"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.categoryID = try container.decode(String.self, forKey: .categoryID)
        self.titleID = try container.decode(Int.self, forKey: .titleID)
        self.volNo = try container.decode(String.self, forKey: .volNo)
        self.titleVolName = try container.decode(String.self, forKey: .titleVolName)
        self.authors = try container.decode([BooklifeAuthor].self, forKey: .authors)
        self.genreID = try container.decode(Int.self, forKey: .genreID)
    }
}

struct BooklifeAuthor: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "auth_name"
    }
}

struct BooklifeMangaDetailsData: Codable {
    let titleList: BookLifeMangaDetailsTitleList
    
    enum CodingKeys: String, CodingKey {
        case titleList = "title_list"
    }
}

struct BookLifeMangaDetailsTitleList: Codable {
    let list: [BookLifeMangaChapter]
    
    func getURL() -> String {
        // use the first chapter to get all available chapters
        if let first = list.first {
            return "\(Booklife.shared.baseURL)json/series?title_id=\(String(first.titleID))&vol_no=\(first.chapterID)&type=series_list"
        } else {
            return ""
        }
    }
    func getTitle() -> String {
        return list.first?.title ?? ""
    }
    func getDescription() -> String {
        return list.first?.abst ?? ""
    }
    func getAuthor() -> String {
        return list.first?.author ?? ""
    }
    func getGenres() -> [String] {
        if let genre = list.first?.genre {
            return [ genre ]
        } else {
            return []
        }
    }
    func getIsFinished() -> Bool {
        return list.first?.completeFlag == 1
    }
    func getThumbnailURL() -> String {
        // return first vol
        guard let first = list.first else { return "" }
        return "\(Booklife.shared.thumbnailBaseURL)\(String(first.titleID))/\(first.chapterID)/thumbnail/2L.jpg"
    }
    func getChapters() -> [SourceChapter] {
        // TODO: - Add chapters later...
//        list.map({ data in
//            let url = "\(Booklife.shared.thumbnailBaseURL)\(String(data.titleID))/\(data.chapterID)/thumbnail/2L.jpg"
//            return SourceChapter(url: <#T##String#>, name: <#T##String#>, uploadedDate: <#T##String#>, chapterNumber: <#T##String#>)
//        })
        return []
    }
}

struct BookLifeMangaChapter: Codable {
    let categoryID: String
    let categoryName: String
    let titleID: Int
    let chapterID: String
    let title: String
    let genreID: String
    let genre: String
    let titleVolName: String
    let abst: String
    let author: String
    let completeFlag: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case titleID = "title_id"
        case chapterID = "vol_id"
        case title = "title_name"
        case genreID = "genre_id_path"
        case genre = "genre_name_path"
        case titleVolName = "title_vol_name"
        case abst
        case author = "title_author_name_list"
        case completeFlag = "complete_flg"
    }
}
