//
//  SourceManga.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

struct SourceManga: Codable {
    let id: UUID
    var url: String
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
    var sourceID: String
    
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
    
    init(url: String, title: String? = nil, alias: String? = nil, artist: String? = nil, author: String? = nil, description: String? = nil, genres: [String] = [], status: Status? = nil, thumbnailURL: String? = nil, updateStrategy: UpdateStrategy? = nil, isInitialized: Bool? = nil, chapters: [SourceChapter] = [], sourceID: String) {
        self.id = UUID(from: url)
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
        self.sourceID = sourceID
    }
    
    func getLocalStoragePath() -> URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents
            .appendingPathComponent("tachiyomi")
            .appendingPathComponent(UUID(from: url).uuidString)
    }
}
