//
//  SourceRegistry.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class SourceRegistry {
    static let allSourceIDs: [String] = [
        SenManga.id,
        Ganma.id,
//        "booklife",
        ShonenJumpPlus.id,
    ]
    static let sourceIDToProviderDictionary: [String: SourceProtocol] = [
        SenManga.id: SenManga(),
        Ganma.id: Ganma(),
        ShonenJumpPlus.id: ShonenJumpPlus(),
    ]
    static func getProvider(for sourceID: String) -> SourceProtocol? {
        return sourceIDToProviderDictionary[sourceID]
    }
    
    // TODO: - Change to check it automatically
    struct LanguageGroupedSourceIDs {
        let language: Language
        let sourceIDs: [String]
    }
    static var groupedSourceIDsByLanguage: [LanguageGroupedSourceIDs] = [
        LanguageGroupedSourceIDs(language: .ja, sourceIDs: [ SenManga.id, Ganma.id, ShonenJumpPlus.id ])
    ]
}
