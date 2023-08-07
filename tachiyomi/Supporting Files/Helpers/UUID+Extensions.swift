//
//  UUID+Extensions.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/7/23.
//

import Foundation
import CryptoKit

extension UUID {
    init(from string: String) {
        let fullString = (Bundle.main.bundleIdentifier ?? "com.muhuiyu.tachiyomi") + string
        let hash = Insecure.SHA1.hash(data: Data(fullString.utf8)) // SHA-1 by spec
        var truncatedHash = Array(hash.prefix(16))
        self = NSUUID(uuidBytes: truncatedHash) as UUID
    }
}
