//
//  LibraryViewModel.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxSwift
import RxRelay

class LibraryViewModel: Base.ViewModel {
    private let sourceMangas: BehaviorRelay<[SourceManga]> = BehaviorRelay(value: [])
    let filteredMangas: BehaviorRelay<[SourceManga]> = BehaviorRelay(value: [])
    
    let isLoading = BehaviorRelay(value: true)
}

extension LibraryViewModel {
    func reloadData() {
        isLoading.accept(true)
        let fetchedMangas = LocalStorage.shared.getLibraryMangas()
        sourceMangas.accept(fetchedMangas)
        filteredMangas.accept(fetchedMangas)
        isLoading.accept(false)
    }
    func getNumberOfLibraryMangas() -> Int {
        return LocalStorage.shared.getNumberOfLibraryMangas()
    }
    func filterManga(with query: String) {
        if query.isEmpty {
            filteredMangas.accept(sourceMangas.value)
            return
        }
        let result = sourceMangas.value.filter { manga in
            let attributes: [String] = [
                (manga.author ?? ""), (manga.title ?? ""), (manga.artist ?? "")
            ]
            return attributes.joined(separator: " ").localizedCaseInsensitiveContains(query)
        }
        filteredMangas.accept(result)
    }
    func deleteMangaFromLibrary(at indexPath: IndexPath) {
        let mangaURL = filteredMangas.value[indexPath.row].url
        guard let indexToRemove = sourceMangas.value.firstIndex(where: { $0.url == mangaURL }) else { return }
        var mangas = sourceMangas.value
        mangas.remove(at: indexToRemove)
        sourceMangas.accept(mangas)
        filteredMangas.accept(mangas)
        
        LocalStorage.shared.deleteMangaFromLibrary(for: mangaURL)
    }
}
