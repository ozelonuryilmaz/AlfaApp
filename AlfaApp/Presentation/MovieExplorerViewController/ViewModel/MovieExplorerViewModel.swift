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
    
    // Services
    func fetchInitialData()
    func refreshCurrentGenre()
    func loadMovies(for genreId: Int, forceRefresh: Bool)
    func loadNextPage()
    
    // Coordinator
    func movieTapped(movie: DiscoverResultUIModel)
    
    // Genres Management
    func setCurrentGenre(genreId: Int)
    func getGenreName(for genreId: Int) -> String?
    func getGenre(before genreId: Int) -> GenreUIModel?
    func getGenre(after genreId: Int) -> GenreUIModel?
    func getFirstGenreId() -> Int?
    
    // Cache
    func saveScrollPosition(_ offset: CGPoint, for genreId: Int)
}

final class MovieExplorerViewModel: IMovieExplorerViewModel {
    private let repository: IMovieExplorerRepository
    private let coordinator: IMovieExplorerCoordinator
    private let scrollPositionService: IScrollPositionService
    private var vmLogic: IMovieExplorerVMLogic
    
    var viewState = ScreenStateSubject<MovieExplorerViewState>(nil)
    var errorState = ErrorStateSubject(nil)
    
    init(repository: IMovieExplorerRepository,
         coordinator: IMovieExplorerCoordinator,
         scrollPositionService: IScrollPositionService,
         vmLogic: IMovieExplorerVMLogic) {
        self.repository = repository
        self.coordinator = coordinator
        self.scrollPositionService = scrollPositionService
        self.vmLogic = vmLogic
    }
    
    deinit {
        repository.clearCache()
        scrollPositionService.clearCache()
    }
}


// MARK: Service
internal extension MovieExplorerViewModel {
    
    func fetchInitialData() {
        viewState.value = .initialLoading
        Task { @MainActor in
            do {
                let genresData = try await repository.fetchGenres()
                vmLogic.setGenresResponse(genresData.genres)
                viewState.value = .genresLoaded
                
                if let firstGenreId = vmLogic.getFirstGenreId() {
                    setCurrentGenre(genreId: firstGenreId)
                    loadMovies(for: firstGenreId, forceRefresh: true)
                }
            } catch {
                errorState.value = "Kategoriler yüklenemedi: \(error.localizedDescription)"
            }
        }
    }
    
    func refreshCurrentGenre() {
        guard let genreId = vmLogic.currentGenreId else { return }
        loadMovies(for: genreId, forceRefresh: true)
    }
    
    func loadMovies(for genreId: Int, forceRefresh: Bool) {
        viewState.value = .moviesLoading(genreId: genreId)
        
        Task { @MainActor in
            await loadMoviesInternal(genreId: genreId, page: 1, forceRefresh: forceRefresh, isPagination: false)
        }
    }
    
    func loadNextPage() {
        guard let nextPage = vmLogic.getNextPageForCurrentGenre(),
              let genreId = vmLogic.currentGenreId else { return }
        
        Task { @MainActor in
            await loadMoviesInternal(genreId: genreId, page: nextPage, forceRefresh: false, isPagination: true)
        }
    }
    
    private func loadMoviesInternal(genreId: Int, page: Int, forceRefresh: Bool, isPagination: Bool) async {
        do {
            let discoverResults = try await repository.fetchDiscover(genreId: genreId, page: page, forceRefresh: forceRefresh)
            vmLogic.updateMovies(for: genreId, with: discoverResults)
            
            let movies = vmLogic.getMovies(for: genreId)
            let offset = scrollPositionService.getPosition(for: genreId) ?? .zero
            viewState.value = .moviesLoaded(genreId: genreId, movies: movies, initialOffset: offset, isPagination: isPagination)
        } catch {
            let message = isPagination ? "Sonraki sayfa yüklenemedi" : "Filmler yüklenemedi"
            errorState.value = "\(message): \(error.localizedDescription)"
        }
    }
}


// MARK: Coordinator Actions
internal extension MovieExplorerViewModel {
    
    func movieTapped(movie: DiscoverResultUIModel) {
        coordinator.presentToMoviePlayerVC(with: movie)
    }
}


// MARK: Genres Management
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
        scrollPositionService.savePosition(offset, for: genreId)
    }
}


// MARK: View State Enum
enum MovieExplorerViewState {
    case initialLoading
    case genresLoaded
    case moviesLoading(genreId: Int)
    case moviesLoaded(genreId: Int, movies: [DiscoverResultUIModel], initialOffset: CGPoint, isPagination: Bool)
}
