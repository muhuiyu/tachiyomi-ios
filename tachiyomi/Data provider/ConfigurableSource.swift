//
//  ConfigurableSource.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/5/23.
//

import Foundation

class ConfigurableSource: SourceProtocol {
    
    // MARK: - Basic information
    var language: Language {
        // Should be implemented in subclass
        return .ja
    }
    
    var supportsLatest: Bool {
        // Should be implemented in subclass
        return true
    }
    
    var name: String {
        return "Should be implemented in subclass"
    }
    
    var baseURL: String {
        return "Should be implemented in subclass"
    }
    
    internal func getPopularMangaRequest(at page: Int) -> URLRequest? {
        // Should be implemented in subclass
        return nil
    }
    
    // MARK: - Get popular manga
    func getPopularManga(at page: Int) async -> MangaPage {
        // Should be implemented in subclass
        return MangaPage(mangas: [], hasNextPage: false)
    }
    
    func parsePopularManga(from data: Data) -> [SourceManga] {
        // Should be implemented in subclass
        return []
    }
    
    internal func getMangaRequest(for identifier: String) -> URLRequest? {
        // Should be implemented in subclass
        return nil
    }
    
    func getManga(from urlString: String) async -> SourceManga? {
        guard let request = getMangaRequest(for: urlString) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return parseManga(from: data)
        } catch {
            print("An error occurred: \(error)")
            return nil
        }
    }
    
    internal func parseManga(from data: Data) -> SourceManga? {
        // Should be implemented in subclass
        return nil
    }
}
