//
//  MovieExplorerViewModel.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation

protocol IMovieExplorerViewModel: AnyObject {
    var viewState: ScreenStateSubject<MovieExplorerViewState> { get }
    var errorState: ErrorStateSubject { get }
    
    init(repository: IMovieExplorerRepository,
         coordinator: IMovieExplorerCoordinator,
         vmLogic: IMovieExplorerVMLogic,
         cacheService: IMovieCacheService)
    
    // Services
    func fetchInitialData()
    func loadMovies(for genreId: Int)
    func loadNextPage()
    
    // Genres
    func setCurrentGenre(genreId: Int)
    func getGenreName(for genreId: Int) -> String?
    func getGenre(before genreId: Int) -> GenreUIModel?
    func getGenre(after genreId: Int) -> GenreUIModel?
    func getFirstGenreId() -> Int?
    
    // Cache
    func saveScrollPosition(_ offset: CGPoint, for genreId: Int)
}

final class MovieExplorerViewModel: BaseViewModel, IMovieExplorerViewModel {
    private let repository: IMovieExplorerRepository
    private let coordinator: IMovieExplorerCoordinator
    private var vmLogic: IMovieExplorerVMLogic
    private let cacheService: IMovieCacheService
    
    var viewState = ScreenStateSubject<MovieExplorerViewState>(nil)
    var errorState = ErrorStateSubject(nil)
    
    required init(repository: IMovieExplorerRepository,
                  coordinator: IMovieExplorerCoordinator,
                  vmLogic: IMovieExplorerVMLogic,
                  cacheService: IMovieCacheService) {
        self.repository = repository
        self.coordinator = coordinator
        self.vmLogic = vmLogic
        self.cacheService = cacheService
        super.init()
    }
}

// MARK: Services
internal extension MovieExplorerViewModel {
    
    func fetchInitialData() {
        viewState.value = .initialLoading
        Task { @MainActor in
            do {
                let genresData = try await repository.fetchGenres()
                self.vmLogic.setGenresResponse(genresData.genres)
                viewState.value = .genresLoaded
                
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
        guard let genreId = self.vmLogic.currentGenreId,
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
}

// MARK: Genres
internal extension MovieExplorerViewModel {
    
    func setCurrentGenre(genreId: Int) {
        vmLogic.setCurrentGenre(genreId: genreId)
    }
    
    func getGenreName(for genreId: Int) -> String? {
        return vmLogic.getGenreName(for: genreId)
    }
    
    func getGenre(before genreId: Int) -> GenreUIModel? {
        return vmLogic.getGenre(before: genreId)
    }
    
    func getGenre(after genreId: Int) -> GenreUIModel? {
        return vmLogic.getGenre(after: genreId)
    }
    
    func getFirstGenreId() -> Int? {
        return vmLogic.getFirstGenreId()
    }
}

// MARK: Cache
internal extension MovieExplorerViewModel {
    
    func saveScrollPosition(_ offset: CGPoint, for genreId: Int) {
        cacheService.updateContentOffset(offset, for: genreId)
    }
}

enum MovieExplorerViewState {
    case initialLoading
    case genresLoaded
    case moviesLoading(genreId: Int)
    case moviesLoaded(genreId: Int, movies: [DiscoverResultUIModel], initialOffset: CGPoint)
}
