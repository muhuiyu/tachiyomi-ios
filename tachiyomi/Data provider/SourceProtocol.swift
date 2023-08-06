//
//  SourceProtocol.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import Foundation

protocol SourceProtocol {
    var language: Language { get }
    var supportsLatest: Bool { get }
    var name: String { get }
    var baseURL: String { get }
    
    func getPopularManga(at page: Int) async -> MangaPage
    func getManga(from urlString: String) async -> SourceManga?
}
