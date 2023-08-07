//
//  ChapterPage.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import Foundation

struct ChapterPage {
    let pageURL: String?
    let pageNumber: Int
    let imageURL: String?
    let width: CGFloat?
    let height: CGFloat?
    
    init(pageURL: String? = nil, pageNumber: Int, imageURL: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.pageURL = pageURL
        self.pageNumber = pageNumber
        self.imageURL = imageURL
        self.width = width
        self.height = height
    }
}
