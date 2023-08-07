//
//  SourceProtocol.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import Foundation

protocol SourceProtocol {
    var sourceID: String { get }
    var language: Language { get }
    var supportsLatest: Bool { get }
    var name: String { get }
    var logo: String { get }
    var baseURL: String { get }
    var isDateInReversed: Bool { get }
    
    func getPopularManga(at page: Int) async -> MangaPage
//    func getLatestManga(at page: Int) async -> MangaPage
    func getManga(from urlString: String) async -> SourceManga?
    func searchMangas(for query: String, at page: Int) async -> MangaPage
    func getChapterPages(from chapter: SourceChapter) async -> Result<[ChapterPage], Error>
    func refetchChapterPage(from pageURL: String, at pageNumber: Int) async -> ChapterPage?
}

// MARK: - SourceError
enum SourceError: Error {
    case noPageFound
    case generic
    case contentNotAvailable
    case countryNotSupported
}
