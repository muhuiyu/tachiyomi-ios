//
//  SourceRegistry.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import Foundation

class SourceRegistry {
    static let allSourceIDs: [String] = Array(sourceIDToProviderDictionary.keys)
    
    static let sourceIDToProviderDictionary: [String: SourceProtocol] = [
        SenManga.id: SenManga(),
        Ganma.id: Ganma(),
        ShonenJumpPlus.id: ShonenJumpPlus(),
        ComicDays.id: ComicDays(),
        ComicGardo.id: ComicGardo(),
        MagComi.id: MagComi(),
        SundayWebEvery.id: SundayWebEvery(),
        CorocoroOnline.id: CorocoroOnline(),
        VizShonenJump.id: VizShonenJump(),
        ComicKEN.id: ComicKEN(),
        ComicKZHHK.id: ComicKZHHK(),
        ComicKVI.id: ComicKVI(),
    ]
    
    static func getProvider(for sourceID: String) -> SourceProtocol? {
        return sourceIDToProviderDictionary[sourceID]
    }
    
    static func getRecentGroups() -> [LanguageGroupedSourceIDs] {
        return getGroups(for: LocalStorage.shared.getRecentSourceIDs())
    }
    
    static func getAllGroups() -> [LanguageGroupedSourceIDs] {
        return getGroups(for: SourceRegistry.allSourceIDs)
    }
    
    static func getGroups(for ids: [String]) -> [LanguageGroupedSourceIDs] {
        var grouped = [Language: [String]]()
        ids.forEach { sourceID in
            if let language = sourceIDToProviderDictionary[sourceID]?.language {
                if grouped[language] != nil {
                    grouped[language]?.append(sourceID)
                } else {
                    grouped[language] = [sourceID]
                }
            }
        }
        return grouped.map { LanguageGroupedSourceIDs(language: $0.key, sourceIDs: $0.value) }
    }
}

struct LanguageGroupedSourceIDs {
    let language: Language
    var sourceIDs: [String]
}
