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
    
    private let sources = Source.allCases
    
    var sourceSections: [(Language, [Source])] {
        return sources.reduce(into: [Language: [Source]]()) { partialResult, source in
            if let _ = partialResult[source.language] {
                partialResult[source.language]?.append(source)
            } else {
                partialResult[source.language] = [source]
            }
        }.sorted(by: { $0.key.rawValue < $1.key.rawValue })
    }
}

extension BrowseViewModel {
    func getSource(at indexPath: IndexPath) -> Source {
        return sources[indexPath.row]
    }
    func getSourceName(at indexPath: IndexPath) -> String {
        return sources[indexPath.row].name
    }
    func getSourceLanguage(at indexPath: IndexPath) -> String {
        return sources[indexPath.row].language.localizedName
    }
    func getSourceThumbnailURL(at indexPath: IndexPath) -> String {
        return sources[indexPath.row].logo
    }
}
