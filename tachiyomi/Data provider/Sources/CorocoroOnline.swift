//
//  CorocoroOnline.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class CorocoroOnline: StandardHTTPSource {
    static let id = "corocoroOnline"
    override var sourceID: String { return CorocoroOnline.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "コロコロオンライン" }
    override var logo: String { return "corocoro-online-logo" }
    override var baseURL: String { return "https://corocoro.jp" }
    
    override var popularMangaSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "ul.series-list li",
                                 link: "a",
                                 title: "a h2.series-list-title",
                                 image: [ "a div.series-list-thumb img", "data-src" ],
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

