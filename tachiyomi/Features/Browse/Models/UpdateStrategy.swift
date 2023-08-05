//
//  UpdateStrategy.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import Foundation

enum UpdateStrategy: Codable {
    case alwaysUpdate
    case onlyFetchOnce
}
