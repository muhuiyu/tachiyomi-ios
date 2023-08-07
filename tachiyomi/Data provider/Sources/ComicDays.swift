//
//  ComicDays.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class ComicDays: StandardHTTPSource {
    static let id = "comicDays"
    override var sourceID: String { return ComicDays.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "コミックDAYS" }
    override var logo: String { return "comic-days-logo" }
    override var baseURL: String { return "https://comic-days.com" }
    
    override var popularMangaSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "ul.daily-series li.daily-series-item",
                                 link: "div.daily-series-thumb a",
                                 title: "div.daily-series-title-container h4.daily-series-title",
                                 image: [ "div.daily-series-thumb a img", "data-src" ],
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
