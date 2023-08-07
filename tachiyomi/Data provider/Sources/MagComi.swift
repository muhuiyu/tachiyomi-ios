//
//  MagComi.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class MagComi: StandardHTTPSource {
    static let id = "magComi"
    override var sourceID: String { return MagComi.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "MAGCOMI" }
    override var logo: String { return "mag-comi-logo" }
    override var baseURL: String { return "https://magcomi.com" }
    
    override var popularMangaSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "ul.series-series-list li",
                                 link: "a",
                                 title: "a h3.series-title",
                                 image: [ "a div.series-thumb img", "src" ],
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
