//
//  SourceChapter.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import Foundation

struct SourceChapter: Codable {
    var url: String
    var name: String
    var uploadedDate: String
    var chapterNumber: String
    var scanlator: String?
}
