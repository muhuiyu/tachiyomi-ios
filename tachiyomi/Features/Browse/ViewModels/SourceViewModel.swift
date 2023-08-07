//
//  SourceViewModel.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxSwift
import RxRelay

class SourceViewModel: Base.ViewModel {
    let source: Source
    let sourceMangas: BehaviorRelay<[SourceManga]> = BehaviorRelay(value: [])
    let isLoading = BehaviorRelay(value: true)
    
    // infinite scroll
    private(set) var hasNextPage = true
    private var currentPage = 0
    
    init(appCoordinator: AppCoordinator? = nil, source: Source) {
        self.source = source
        super.init(appCoordinator: appCoordinator)
        fetchNextPage()
    }
}

extension SourceViewModel {
    func fetchNextPage() {
        if !hasNextPage { return }
        currentPage += 1
        reloadData()
    }
    func searchMangas(for query: String) {
        currentPage = 1
        reloadData(for: query)
    }
    private func reloadData(for query: String = "") {
        isLoading.accept(true)
        
        // if currentPage = 1 (start new search or clear search), clear sourceMangas
        if currentPage == 1 {
            hasNextPage = true
            sourceMangas.accept([])
        }
        
        Task {
            let result = await fetchData(for: query)
            sourceMangas.accept(sourceMangas.value + result.mangas)
            hasNextPage = result.hasNextPage
            isLoading.accept(false)
        }
    }
    func addMangaToLibary(at indexPath: IndexPath) {
        guard let mangaURL = sourceMangas.value[indexPath.row].url else { return }
        LocalStorage.shared.addToLibrary(for: mangaURL)
    }
}

// MARK: - Private methods
extension SourceViewModel {
    private func fetchData(for query: String) async -> MangaPage {
        switch source {
        case .senManga:
            if query.isEmpty {
                return await SenManga.shared.getPopularManga(at: currentPage)
            } else {
                return await SenManga.shared.searchMangas(for: query, at: currentPage)
            }
        case .ganma:
            // haven't completed search function yet
            return await Ganma.shared.getPopularManga(at: currentPage)
        case .shonenJumpPlus:
            // haven't completed search function yet
            if let source = LocalStorage.shared.standardSources[.shonenJumpPlus] {
                return await source.getPopularManga(at: currentPage)
            } else {
                return MangaPage(mangas: [], hasNextPage: false)
            }
        }
    }
}


