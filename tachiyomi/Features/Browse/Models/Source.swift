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
    case booklive
    
    var name: String {
        switch self {
        case .senManga:
            return "Sen Manga"
        case .ganma:
            return "Ganma"
        case .booklive:
            return "Booklive"
        }
    }
    
    var language: Language {
        switch self {
        case .senManga, .ganma, .booklive:
            return .ja
        }
    }
    
    var filters: [SourceFilter] {
        switch self {
        case .senManga:
            return [.popular, .latest]
        case .ganma:
            return [.popular]
        case .booklive:
            return [.popular, .latest]
        }
    }
    
    var logo: String {
        switch self {
        case .senManga:
            return "sen-manga-logo"
        case .ganma:
            return "ganma-logo"
        case .booklive:
            return "booklive-logo"
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
