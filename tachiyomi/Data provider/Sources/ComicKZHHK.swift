//
//  ComicKZHHK.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/8/23.
//

import Foundation

/// ComicK in Traditional Chinese
class ComicKZHHK: ComicK {
    static let id = "comicKZHHK"
    override var language: Language { return .zhhk }
    override var sourceID: String { return ComicKZHHK.id }
}
