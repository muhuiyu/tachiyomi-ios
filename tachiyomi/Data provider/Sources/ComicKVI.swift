//
//  ComicKVI.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/8/23.
//

import Foundation

/// ComicK in Vietnamese
class ComicKVI: ComicK {
    static let id = "comicKVI"
    override var language: Language { return .vi }
    override var sourceID: String { return ComicKVI.id }
}
