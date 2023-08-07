//
//  ShonenJumpPlus.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class ShonenJumpPlus: StandardHTTPSource {
    static let id = "shonenJumpPlus"
    override var sourceID: String { return ShonenJumpPlus.id }
    override var language: Language { return .ja }
    override var supportsLatest: Bool { return true }
    override var name: String { return "少年ジャンプ+" }
    override var logo: String { return "shonen-jump-logo" }
    override var baseURL: String { return "https://shonenjumpplus.com" }
}
