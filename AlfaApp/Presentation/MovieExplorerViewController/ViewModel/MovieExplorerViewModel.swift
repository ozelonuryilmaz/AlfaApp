//
//  MovieExplorerViewModel.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import Foundation
import Combine

// MARK: ViewState
enum MovieExplorerViewState {
    case showLoading(isProgress: Bool)
    case display(genreId: Int, genreTitle: String, movies: [MovieItemViewModel])
    case showPaginationLoading(isProgress: Bool)
}

// MARK: Cache Model
struct GenreMoviesState {
    var movies: [DiscoverResultUIModel]
    var currentPage: Int
    var totalPages: Int
    var canLoadMore: Bool { currentPage < totalPages }
}

// MARK: ViewModel Protocol
protocol IMovieExplorerViewModel: AnyObject {
    var viewState: CurrentValueSubject<MovieExplorerViewState?, Never> { get }
    var errorState: PassthroughSubject<String, Never> { get }
    
    func initialLoad()
    func didSwipe(direction: SwipeDirection)
    func loadMoreMovies()
}

// MARK: ViewModel Implementation
final class MovieExplorerViewModel: IMovieExplorerViewModel {

    // MARK: Dependencies
    private let repository: IMovieExplorerRepository
    private let coordinator: IMovieExplorerCoordinator
    private let vmLogic: IMovieExplorerVMLogic
    
    // MARK: State & Cache
    var viewState = CurrentValueSubject<MovieExplorerViewState?, Never>(nil)
    var errorState = PassthroughSubject<String, Never>()
    
    private var currentGenreIndex: Int = 0
    private var genres: [GenreUIModel] = []
    private var movieCache = [Int: GenreMoviesState]()
    private var isPaginating = false
    
    // MARK: Initializer
    init(repository: IMovieExplorerRepository,
         coordinator: IMovieExplorerCoordinator,
         vmLogic: IMovieExplorerVMLogic) {
        self.repository = repository
        self.coordinator = coordinator
        self.vmLogic = vmLogic
    }
    
    // MARK: Public Methods
    func initialLoad() {
        Task { await fetchGenresAndFirstCategoryMovies() }
    }
    
    func didSwipe(direction: SwipeDirection) {
        guard let newIndex = vmLogic.calculateIndex(for: direction, currentIndex: currentGenreIndex, totalCount: genres.count) else { return }
        currentGenreIndex = newIndex
        loadMoviesForCurrentGenre()
    }
    
    func loadMoreMovies() {
        guard !isPaginating,
              let currentGenre = genres[safe: currentGenreIndex],
              let currentState = movieCache[currentGenre.id],
              currentState.canLoadMore else { return }
        
        isPaginating = true
        viewState.send(.showPaginationLoading(isProgress: true))
        let pageToLoad = currentState.currentPage + 1
        
        Task { @MainActor in
            do {
                let moviesResult = try await repository.fetchDiscover(genreId: currentGenre.id, page: pageToLoad)
                
                var updatedState = currentState
                updatedState.movies.append(contentsOf: moviesResult.results)
                updatedState.currentPage = moviesResult.page
                
                movieCache[currentGenre.id] = updatedState
                let itemViewModels = updatedState.movies.map { MovieItemViewModel(movie: $0) }
                viewState.send(.display(genreId: currentGenre.id, genreTitle: currentGenre.name, movies: itemViewModels))
                
            } catch {
                errorState.send(error.localizedDescription)
            }
            
            isPaginating = false
            viewState.send(.showPaginationLoading(isProgress: false))
        }
    }
    
    // MARK: Private Methods
    private func fetchGenresAndFirstCategoryMovies() async {
        viewState.send(.showLoading(isProgress: true))
        do {
            let genresResult: GenresUIModel = try await repository.fetchGenres()
            self.genres = genresResult.genres
            
            if !genres.isEmpty {
                loadMoviesForCurrentGenre()
            } else {
                errorState.send("Film kategorileri bulunamadı.")
                viewState.send(.showLoading(isProgress: false))
            }
        } catch {
            errorState.send(error.localizedDescription)
            viewState.send(.showLoading(isProgress: false))
        }
    }
    
    private func loadMoviesForCurrentGenre() {
        guard let currentGenre = genres[safe: currentGenreIndex] else { return }
        
        if let cachedState = movieCache[currentGenre.id] {
            let itemViewModels = cachedState.movies.map { MovieItemViewModel(movie: $0) }
            viewState.send(.display(genreId: currentGenre.id, genreTitle: currentGenre.name, movies: itemViewModels))
            return
        }
        
        Task { @MainActor in
            viewState.send(.showLoading(isProgress: true))
            do {
                // Not: Repository'nizin ve DiscoverResultsUIModel'inizin API'den 'total_pages'
                // alanını alıp işlediğinden emin olun.
                let moviesResult = try await repository.fetchDiscover(genreId: currentGenre.id, page: 1)
                let newState = GenreMoviesState(
                    movies: moviesResult.results,
                    currentPage: moviesResult.page,
                    totalPages: moviesResult.total_pages
                )
                movieCache[currentGenre.id] = newState
                
                let itemViewModels = newState.movies.map { MovieItemViewModel(movie: $0) }
                viewState.send(.display(genreId: currentGenre.id, genreTitle: currentGenre.name, movies: itemViewModels))
                
            } catch {
                errorState.send(error.localizedDescription)
            }
            viewState.send(.showLoading(isProgress: false))
        }
    }
}

// Güvenli dizi erişimi için helper
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
