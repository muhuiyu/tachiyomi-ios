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
    var artist: String?
    var author: String?
    var description: String?
    var genre: [String]
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
    
    init(url: String? = nil, title: String? = nil, artist: String? = nil, author: String? = nil, description: String? = nil, genre: [String] = [], status: Status? = nil, thumbnailURL: String? = nil, updateStrategy: UpdateStrategy? = nil, isInitialized: Bool? = nil, chapters: [SourceChapter] = [], source: Source) {
        self.url = url
        self.title = title
        self.artist = artist
        self.author = author
        self.description = description
        self.genre = genre
        self.status = status
        self.thumbnailURL = thumbnailURL
        self.updateStrategy = updateStrategy
        self.isInitialized = isInitialized
        self.chapters = chapters
        self.source = source
    }
}

extension SourceManga {
    static let testEntry: SourceManga = SourceManga(
        url: "https://raw.senmanga.com/isekai-maou-to-shoukan-shoujo-dorei-majutsu",
        title: "Isekai Maou to Shoukan Shoujo Dorei Majutsu",
        description: "In the MMORPG Cross Reverie, Takuma Sakamoto is so powerful that he is lauded as the âDemon Lordâ by other players. One day, he is summoned to a world outside his ownâ but with the same appearance he had in the game! There, he meets two girls who both proclaim themselves to be his Summoner. They perform an Enslavement Ritual to turn him into their Summonâ¦ but thatâs when Takumaâs passive ability <<Magic Reflection>> activates! Instead, it is the girls who become enslaved! Though Takuma may be the strongest Sorcerer there is, he has no idea how to talk with other people. It is here he makes his choice: to act based on his persona from the game! âAmazing? But of courseâ¦ I am Diablo, the being known and feared as the Demon Lord!â So begins a tale of adventure with an earth-shakingly powerful Demon Lord (or at least someone who acts like one) taking on another world!",
        genre: ["fight", "cute"],
        status: .ongoing,
        thumbnailURL: "https://raw.senmanga.com/covers/isekai-maou-to-shoukan-shoujo-dorei-majutsu.jpg",
        chapters: [SourceChapter(url: "https://raw.senmanga.com/isekai-maou-to-shoukan-shoujo-dorei-majutsu/9", name: "Chapter 9", uploadedDate: "1 year ago", chapterNumber: "9", scanlator: nil), SourceChapter(url: "https://raw.senmanga.com/isekai-maou-to-shoukan-shoujo-dorei-majutsu/8", name: "Chapter 8", uploadedDate: "1 year ago", chapterNumber: "8", scanlator: nil), SourceChapter(url: "https://raw.senmanga.com/isekai-maou-to-shoukan-shoujo-dorei-majutsu/7", name: "Chapter 7", uploadedDate: "1 year ago", chapterNumber: "7", scanlator: nil)],
        source: .senManga
    )
}
