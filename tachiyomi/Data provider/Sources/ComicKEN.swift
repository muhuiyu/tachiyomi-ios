//
//  ComicKEN.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/8/23.
//

import Foundation

/// ComicK in English
class ComicKEN: ComicK {
    static let id = "comicKEN"
    override var language: Language { return .en }
    override var sourceID: String { return ComicKEN.id }
}
