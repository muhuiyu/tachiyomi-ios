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
    
    // Sen Manga only
    var scanlator: String?
    
    // Ganma only
    var ganmaPage: GanmaMagazinePage?
    
    init(url: String, name: String, uploadedDate: String, chapterNumber: String, scanlator: String? = nil, ganmaPage: GanmaMagazinePage? = nil) {
        self.url = url
        self.name = name
        self.uploadedDate = uploadedDate
        self.chapterNumber = chapterNumber
        self.scanlator = scanlator
        self.ganmaPage = ganmaPage
    }
}
