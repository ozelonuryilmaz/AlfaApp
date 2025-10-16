//
//  MovieExplorerViewModel.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation
import CoreGraphics

protocol IMovieExplorerViewModel: AnyObject {
    var viewState: ScreenStateSubject<MovieExplorerViewState> { get }
    var errorState: ErrorStateSubject { get }
    var genres: [GenreUIModel] { get }
    var currentGenreId: Int? { get }
    
    init(repository: IMovieExplorerRepository, coordinator: IMovieExplorerCoordinator, vmLogic: IMovieExplorerVMLogic, cacheService: IMovieCacheService)
    
    func fetchInitialData()
    func loadMovies(for genreId: Int)
    func loadNextPage()
    func saveScrollPosition(_ offset: CGPoint, for genreId: Int)
    func setCurrentGenre(genreId: Int)
}

final class MovieExplorerViewModel: BaseViewModel, IMovieExplorerViewModel {
    
    private let repository: IMovieExplorerRepository
    private let coordinator: IMovieExplorerCoordinator
    private var vmLogic: IMovieExplorerVMLogic
    private let cacheService: IMovieCacheService
    
    var viewState = ScreenStateSubject<MovieExplorerViewState>(nil)
    var errorState = ErrorStateSubject(nil)
    
    var genres: [GenreUIModel] { vmLogic.genres }
    var currentGenreId: Int? { vmLogic.currentGenreId }

    required init(repository: IMovieExplorerRepository, coordinator: IMovieExplorerCoordinator, vmLogic: IMovieExplorerVMLogic, cacheService: IMovieCacheService) {
        self.repository = repository
        self.coordinator = coordinator
        self.vmLogic = vmLogic
        self.cacheService = cacheService
        super.init()
    }

    func fetchInitialData() {
        viewState.value = .initialLoading
        Task { @MainActor in
            do {
                let genresData = try await repository.fetchGenres()
                self.vmLogic.genres = genresData.genres
                viewState.value = .genresLoaded
                
                // VMLogic'ten ilk genre ID'sini al ve mevcut genre olarak ayarla
                if let firstGenreId = self.vmLogic.getFirstGenreId() {
                    self.setCurrentGenre(genreId: firstGenreId)
                    loadMovies(for: firstGenreId)
                }
            } catch {
                errorState.value = "Kategoriler yüklenemedi: \(error.localizedDescription)"
            }
        }
    }
    
    func loadMovies(for genreId: Int) {
        if let cachedEntry = cacheService.getEntry(for: genreId) {
            viewState.value = .moviesLoaded(genreId: genreId, movies: cachedEntry.movies, initialOffset: cachedEntry.lastContentOffset)
            return
        }
        
        viewState.value = .moviesLoading(genreId: genreId)
        Task { @MainActor in
            do {
                let discoverResults = try await repository.fetchDiscover(genreId: genreId, page: 1)
                let newEntry = GenreCacheEntry(movies: discoverResults.results, currentPage: 1, lastContentOffset: .zero)
                cacheService.cache(entry: newEntry, for: genreId)
                viewState.value = .moviesLoaded(genreId: genreId, movies: newEntry.movies, initialOffset: .zero)
            } catch {
                errorState.value = "Filmler yüklenemedi: \(error.localizedDescription)"
            }
        }
    }

    func loadNextPage() {
        guard let genreId = self.currentGenreId,
              let currentEntry = cacheService.getEntry(for: genreId) else { return }
        let nextPage = currentEntry.currentPage + 1
        
        Task { @MainActor in
            do {
                let discoverResults = try await repository.fetchDiscover(genreId: genreId, page: nextPage)
                
                guard let newEntry = vmLogic.processNextPage(currentEntry: currentEntry, newResults: discoverResults) else {
                    return
                }
                
                cacheService.cache(entry: newEntry, for: genreId)
                viewState.value = .moviesLoaded(genreId: genreId, movies: newEntry.movies, initialOffset: newEntry.lastContentOffset)
                
            } catch {
                print("Failed to load next page: \(error.localizedDescription)")
            }
        }
    }
    
    func saveScrollPosition(_ offset: CGPoint, for genreId: Int) {
        cacheService.updateContentOffset(offset, for: genreId)
    }
    
    func setCurrentGenre(genreId: Int) {
        vmLogic.setCurrentGenre(genreId: genreId)
    }
}

enum MovieExplorerViewState {
    case initialLoading
    case genresLoaded
    case moviesLoading(genreId: Int)
    case moviesLoaded(genreId: Int, movies: [DiscoverResultUIModel], initialOffset: CGPoint)
}
