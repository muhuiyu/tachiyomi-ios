//
//  BrowseViewModel.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxSwift
import RxRelay

class BrowseViewModel: Base.ViewModel {
    private let sourceIDs = LocalStorage.shared.getRecentSourceIDs()
    let sections: BehaviorRelay<[LanguageGroupedSourceIDs]> = BehaviorRelay(value: [])
    
    private(set) var mode: SourceGroup = .recent
    
    enum SourceGroup {
        case recent
        case all
    }
}

extension BrowseViewModel {
    func updateSources(to type: SourceGroup) {
        mode = type
        switch type {
        case .recent:
            sections.accept(SourceRegistry.getRecentGroups())
        case .all:
            sections.accept(SourceRegistry.getAllGroups())
        }
    }
    func saveSource(at indexPath: IndexPath) {
        let id = getSourceID(at: indexPath)
        LocalStorage.shared.saveSourceID(for: id)
    }
    func unsaveSource(at indexPath: IndexPath) {
        let id = getSourceID(at: indexPath)
        LocalStorage.shared.unsaveSourceID(for: id)
        var updatedSections = sections.value
        updatedSections[indexPath.section].sourceIDs.remove(at: indexPath.row)
        sections.accept(updatedSections)
    }
    func getNumberOfSections() -> Int {
        return sections.value.count
    }
    func getNumberOfRows(at section: Int) -> Int {
        return sections.value[section].sourceIDs.count
    }
    func getTitle(at section: Int) -> String {
        return sections.value[section].language.localizedName
    }
    func getSourceID(at indexPath: IndexPath) -> String {
        return sections.value[indexPath.section].sourceIDs[indexPath.row]
    }
    func getSourceName(at indexPath: IndexPath) -> String {
        let sourceID = getSourceID(at: indexPath)
        return SourceRegistry.getProvider(for: sourceID)?.name ?? ""
    }
    func getSourceLanguage(at indexPath: IndexPath) -> String {
        let sourceID = getSourceID(at: indexPath)
        return SourceRegistry.getProvider(for: sourceID)?.language.localizedName ?? ""
    }
    func getSourceThumbnailURL(at indexPath: IndexPath) -> String {
        let sourceID = getSourceID(at: indexPath)
        return SourceRegistry.getProvider(for: sourceID)?.logo ?? ""
    }
}
