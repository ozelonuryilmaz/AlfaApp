//
//  MovieExplorerViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit

final class MovieExplorerViewController: AlfaBaseViewController<MovieExplorerRootView> {
    
    private let viewModel: IMovieExplorerViewModel
    private var genreViewControllers: [Int: GenreMoviesViewController] = [:]
    
    init(viewModel: IMovieExplorerViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setLayoutStyle() -> (top: EdgeLayoutStyle, leading: EdgeLayoutStyle, bottom: EdgeLayoutStyle, trailing: EdgeLayoutStyle) {
        return (.safeArea, .superview, .superview, .superview)
    }
    
    override func setupView() {
        rootView.pageViewController.dataSource = self
        rootView.pageViewController.delegate = self
    }
    
    override func initialComponents() {
        observeViewState()
        listenErrorState()
        viewModel.fetchInitialData()
    }
}


// MARK: Observable
private extension MovieExplorerViewController {
    
    func observeViewState() {
        viewModel.viewState
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handle(state: state)
            }
            .store(in: &cancelBag)
    }
    
    func handle(state: MovieExplorerViewState) {
        switch state {
        case .initialLoading:
            rootView.showInitialLoading(true)
        case .genresLoaded:
            rootView.showInitialLoading(false)
            setupInitialPage()
        case .moviesLoading(let genreId):
            genreViewControllers[genreId]?.showLoading()
        case .moviesLoaded(let genreId, let movies, let initialOffset, let isPagination):
            genreViewControllers[genreId]?.update(with: movies, initialOffset: initialOffset, isPagination: isPagination)
        }
    }
    
    func listenErrorState() {
        viewModel.errorState
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                print("Error: \(errorMessage)")
                self?.rootView.showInitialLoading(false)
            }
            .store(in: &cancelBag)
    }
}


// MARK: InitialPage
private extension MovieExplorerViewController {
    
    func setupInitialPage() {
        guard let firstGenreId = viewModel.getFirstGenreId() else { return }
        let firstVC = viewController(for: firstGenreId)
        rootView.setInitialPage(viewController: firstVC)
        updateNavigationTitle(for: firstGenreId)
    }
    
    func viewController(for genreId: Int) -> GenreMoviesViewController {
        if let existingVC = genreViewControllers[genreId] { return existingVC }
        let newVC = GenreMoviesViewController(genreId: genreId)
        newVC.onRequiresNextPage = { [weak self] in self?.viewModel.loadNextPage() }
        newVC.onMovieTapped = { [weak self] movie in self?.viewModel.movieTapped(movie: movie) }
        genreViewControllers[genreId] = newVC
        return newVC
    }
}


// MARK: Navigation
private extension MovieExplorerViewController {
    
    func updateNavigationTitle(for genreId: Int) {
        self.title = viewModel.getGenreName(for: genreId)
    }
}


// MARK: UIPageViewControllerDataSource & UIPageViewControllerDelegate
extension MovieExplorerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? GenreMoviesViewController,
              let previousGenre = viewModel.getGenre(before: currentVC.genreId) else { return nil }
        return self.viewController(for: previousGenre.id)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? GenreMoviesViewController,
              let nextGenre = viewModel.getGenre(after: currentVC.genreId) else { return nil }
        return self.viewController(for: nextGenre.id)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        if let previousVC = previousViewControllers.first as? GenreMoviesViewController {
            viewModel.saveScrollPosition(previousVC.currentContentOffset, for: previousVC.genreId)
        }
        
        if let currentVC = pageViewController.viewControllers?.first as? GenreMoviesViewController {
            viewModel.setCurrentGenre(genreId: currentVC.genreId)
            viewModel.loadMovies(for: currentVC.genreId)
            updateNavigationTitle(for: currentVC.genreId)
        }
    }
}
