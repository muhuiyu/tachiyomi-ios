//
//  ChapterPage.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import Foundation
import Kingfisher

struct ChapterPage {
    let pageURL: String?
    let pageNumber: Int
    let imageURL: String?
    let width: CGFloat?
    let height: CGFloat?
    let modifier: AnyModifier?
    
    init(pageURL: String? = nil, pageNumber: Int, imageURL: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, modifier: AnyModifier? = nil) {
        self.pageURL = pageURL
        self.pageNumber = pageNumber
        self.imageURL = imageURL
        self.width = width
        self.height = height
        self.modifier = modifier
    }
}
