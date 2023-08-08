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
    let sourceID: String
    let sourceMangas: BehaviorRelay<[SourceManga]> = BehaviorRelay(value: [])
    let isLoading = BehaviorRelay(value: true)
    
    // infinite scroll
    private(set) var hasNextPage = true
    private var currentPage = 0
    
    init(appCoordinator: AppCoordinator? = nil, sourceID: String) {
        self.sourceID = sourceID
        super.init(appCoordinator: appCoordinator)
        fetchNextPage()
    }
}

extension SourceViewModel {
    func getSourceName() -> String {
        return SourceRegistry.getProvider(for: sourceID)?.name ?? ""
    }
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
        let manga = sourceMangas.value[indexPath.row]
        LocalStorage.shared.addToLibrary(for: manga, from: sourceID)
    }
}

// MARK: - Private methods
extension SourceViewModel {
    private func fetchData(for query: String) async -> MangaPage {
        guard let provider = SourceRegistry.getProvider(for: sourceID) else {
            return MangaPage(mangas: [], hasNextPage: false)
        }
        if query.isEmpty {
            return await provider.getPopularManga(at: currentPage)
        } else {
            return await provider.searchMangas(for: query, at: currentPage)
        }
    }
}


