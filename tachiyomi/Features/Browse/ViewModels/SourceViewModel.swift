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
    func reloadData() {
        isLoading.accept(true)
        Task {
            switch source {
            case .senManga:
                let result = await SenManga.shared.getPopularManga(at: currentPage)
                sourceMangas.accept(sourceMangas.value + result.mangas)
                hasNextPage = result.hasNextPage
                isLoading.accept(false)
            case .ganma:
                let result = await Ganma.shared.getPopularManga(at: currentPage)
                sourceMangas.accept(sourceMangas.value + result.mangas)
                hasNextPage = result.hasNextPage
                isLoading.accept(false)
            }
        }
    }
    func addMangaToLibary(at indexPath: IndexPath) {
        guard let mangaURL = sourceMangas.value[indexPath.row].url else { return }
        LocalStorage.shared.addToLibrary(for: mangaURL)
    }
}


