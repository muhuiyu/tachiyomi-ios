//
//  VizShonenJump.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/7/23.
//

import UIKit
import SwiftSoup

class VizShonenJump: Viz {
    static let id = "vizShonenJump"
    override var sourceID: String { return VizShonenJump.id }
    override var language: Language { return .en }
    override var supportsLatest: Bool { return true }
    override var name: String { return "Viz Shonen" }
    override var logo: String { return "viz-shonen-jump-logo" }
    override var baseURL: String { return "https://www.viz.com" }
    override var isDateInReversed: Bool { return true }
    
    override var servicePath: String {
        return "vizmanga"
    }
}

