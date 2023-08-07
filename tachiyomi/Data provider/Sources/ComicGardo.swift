//
//  ComicGardo.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class ComicGardo: StandardHTTPSource {
    static let id = "comicGardo"
    override var sourceID: String { return ComicGardo.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "コミックガルド" }
    override var logo: String { return "comic-gardo-logo" }
    override var baseURL: String { return "https://comic-gardo.com" }
    
    override var popularMangaSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "ul.series-section-list li",
                                 link: "a.series-section-item-link",
                                 title: "a.series-section-item-link h5.series-title",
                                 image: [ "a.series-section-item-link div.thumb img", "data-src" ],
                                 nextPage: nil)
    }
    override var mangaSearchResultSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "ul.search-series-list li, ul.series-list li",
                                 link: "div.thmb-container a",
                                 title: "div.title-box p.series-title",
                                 image: [ "div.thmb-container a img", "src" ],
                                 nextPage: nil)
    }
}

