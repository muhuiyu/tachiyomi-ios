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
    case shonenJumpPlus

    // Other sources to do: corocoroonline, comicdays, comicgardo, kuragebranch, magcomi, sundayWebEvery, tonarinoyoungjump
    
    var name: String {
        switch self {
        case .senManga:
            return "Sen Manga"
        case .ganma:
            return "ガンマ"
        case .shonenJumpPlus:
            return "少年ジャンプ+"
        }
    }
    
    var language: Language {
        switch self {
        case .senManga, .ganma, .shonenJumpPlus:
            return .ja
        }
    }
    
    var filters: [SourceFilter] {
        switch self {
        case .senManga:
            return [.popular, .latest]
        case .ganma:
            return [.popular]
        case .shonenJumpPlus:
            return [.popular, .latest]
        }
    }
    
    var logo: String {
        switch self {
        case .senManga:
            return "sen-manga-logo"
        case .ganma:
            return "ganma-logo"
        case .shonenJumpPlus:
            return "shonen-jump-logo"
        }
    }
    
    var baseURL: String {
        switch self {
        case .senManga:
            return "https://raw.senmanga.com"
        case .ganma:
            return "https://ganma.jp"
        case .shonenJumpPlus:
            return "https://shonenjumpplus.com"
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
