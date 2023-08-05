//
//  Source.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import Foundation

enum Source: CaseIterable, Codable {
    case senManga
    case ganma
    
    var name: String {
        switch self {
        case .senManga:
            return "Sen Manga"
        case .ganma:
            return "Ganma"
        }
    }
    
    var language: Language {
        switch self {
        case .senManga, .ganma:
            return .ja
        }
    }
    
    var filters: [SourceFilter] {
        switch self {
        case .senManga:
            return [.popular, .latest]
        case .ganma:
            return [.popular]
        }
    }
    
    var logo: String {
        switch self {
        case .senManga:
            return "sen-manga-logo"
        case .ganma:
            return "ganma-logo"
        }
    }
}

enum SourceFilter {
    case popular
    case latest
    
    var name: String {
        switch self {
        case .popular:
            return "Popular"
        case .latest:
            return "Latest"
        }
    }
}
