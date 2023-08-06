//
//  SourceManga.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

struct SourceManga: Codable {
    var url: String?
    var title: String?
    var alias: String?
    var artist: String?
    var author: String?
    var description: String?
    var genres: [String]
    var status: Status?
    var thumbnailURL: String?
    var updateStrategy: UpdateStrategy?
    var isInitialized: Bool?
    var chapters: [SourceChapter]
    var source: Source
    
    enum Status: String, Codable {
        case unknown
        case ongoing
        case completed
        case licensed
        case publishingFinished
        case cancelled
        case onHiatus
        
        var name: String {
            switch self {
            case .unknown:
                return "Unknown"
            case .ongoing:
                return "Ongoing"
            case .completed:
                return "Completed"
            case .licensed:
                return "Licensed"
            case .publishingFinished:
                return "Publishing finished"
            case .cancelled:
                return "Cancelled"
            case .onHiatus:
                return "On hiatus"
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .unknown:
                return UIImage(systemName: Icons.questionmarkCircle)
            case .ongoing:
                return UIImage(systemName: Icons.clock)
            case .completed:
                return UIImage(systemName: Icons.checkmark)
            case .licensed:
                return UIImage(systemName: Icons.dollarSignArrowCirclePath)
            case .publishingFinished:
                return UIImage(systemName: Icons.book)
            case .cancelled:
                return UIImage(systemName: Icons.xmark)
            case .onHiatus:
                return UIImage(systemName: Icons.pauseCircle)
            }
        }
    }
    
    init(url: String? = nil, title: String? = nil, alias: String? = nil, artist: String? = nil, author: String? = nil, description: String? = nil, genres: [String] = [], status: Status? = nil, thumbnailURL: String? = nil, updateStrategy: UpdateStrategy? = nil, isInitialized: Bool? = nil, chapters: [SourceChapter] = [], source: Source) {
        self.url = url
        self.title = title
        self.alias = alias
        self.artist = artist
        self.author = author
        self.description = description
        self.genres = genres
        self.status = status
        self.thumbnailURL = thumbnailURL
        self.updateStrategy = updateStrategy
        self.isInitialized = isInitialized
        self.chapters = chapters
        self.source = source
    }
}

// MARK: - Ganma data decoder
extension SourceManga {
    init(from ganmaData: GanmaMangaOverviewRoot) {
        self.url = Ganma.shared.getMangaURL(for: ganmaData.alias)
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
        self.source = .ganma
    }
    init(from magazine: GanmaMagazine) {
        self.url = Ganma.shared.getMangaURL(for: magazine.alias)
        self.title = magazine.title
        self.alias = magazine.alias
        self.author = magazine.author.penName
        self.description = magazine.description
        self.genres = []
        self.status = magazine.flags.isFinished ?? false ? .completed : .ongoing
        self.thumbnailURL = magazine.squareImage.url
        self.updateStrategy = nil
        self.isInitialized = true
        self.chapters = magazine.items.enumerated().map({ $0.element.toChapter(at: $0.offset) })
        self.source = .ganma
    }
}
// MARK: - Booklife
extension SourceManga {
    init(from data: BooklifeMangaOverview) {
        self.url = data.getURL()
        self.title = data.titleVolName
        self.author = data.authors.first?.name
        self.genres = []    // we will do this later
        self.status = .unknown
        self.thumbnailURL = "\(Booklife.shared.thumbnailBaseURL)\(String(data.titleID))/\(data.volNo)/thumbnail/2L.jpg"
        self.updateStrategy = nil
        self.isInitialized = true
        self.chapters = []
        self.source = .booklive
    }
    init(from data: BookLifeMangaDetailsTitleList) {
        self.url = data.getURL()
        self.title = data.getTitle()
        self.author = data.getAuthor()
        self.description = data.getDescription()
        self.genres = data.getGenres()
        self.status = .unknown
        self.thumbnailURL = data.getThumbnailURL()
        self.updateStrategy = nil
        self.isInitialized = true
        self.chapters = data.getChapters()
        self.source = .booklive
    }
}
