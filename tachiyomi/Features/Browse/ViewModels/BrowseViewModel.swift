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
    private let sourceIDs = SourceRegistry.allSourceIDs
}

extension BrowseViewModel {
    func getNumberOfSections() -> Int {
        return SourceRegistry.groupedSourceIDsByLanguage.count
    }
    func getNumberOfRows(at section: Int) -> Int {
        return SourceRegistry.groupedSourceIDsByLanguage[section].sourceIDs.count
    }
    func getTitle(at section: Int) -> String {
        return SourceRegistry.groupedSourceIDsByLanguage[section].language.localizedName
    }
    func getSourceID(at indexPath: IndexPath) -> String {
        return SourceRegistry.groupedSourceIDsByLanguage[indexPath.section].sourceIDs[indexPath.row]
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
