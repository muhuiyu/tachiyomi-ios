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
        ComicK.id: ComicK(),
        
    ]
    static func getProvider(for sourceID: String) -> SourceProtocol? {
        return sourceIDToProviderDictionary[sourceID]
    }
    
    // TODO: - Change to check it automatically
    struct LanguageGroupedSourceIDs {
        let language: Language
        var sourceIDs: [String]
    }
    static var groupedSourceIDsByLanguage: [LanguageGroupedSourceIDs] {
        var list = [LanguageGroupedSourceIDs]()
        sourceIDToProviderDictionary.forEach { (key, value) in
            if let index = list.firstIndex(where: { $0.language == value.language }) {
                list[index].sourceIDs.append(key)
            } else {
                list.append(LanguageGroupedSourceIDs(language: value.language, sourceIDs: [key]))
            }
        }
        return list
    }
}
