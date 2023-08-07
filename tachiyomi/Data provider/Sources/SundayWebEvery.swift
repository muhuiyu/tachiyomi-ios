//
//  SundayWebEvery.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class SundayWebEvery: StandardHTTPSource {
    static let id = "sundayWebEvery"
    override var sourceID: String { return SundayWebEvery.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "サンデーうぇぶり" }
    override var logo: String { return "sunday-web-every-logo" }
    override var baseURL: String { return "https://www.sunday-webry.com" }
    
    override var popularMangaSelector: ParseHTTPSelector {
        return ParseHTTPSelector(main: "ul.webry-series-list li",
                                 link: "a.webry-series-item-link",
                                 title: "a.webry-series-item-link h4.series-title",
                                 image: [ "a.webry-series-item-link div.thumb-wrapper img", "data-src" ],
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

