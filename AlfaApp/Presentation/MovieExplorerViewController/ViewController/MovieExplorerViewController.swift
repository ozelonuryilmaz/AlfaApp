//
//  MovieExplorerViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit
import Combine

final class MovieExplorerViewController: AlfaBaseViewController<MovieExplorerRootView> {
    
    private let viewModel: IMovieExplorerViewModel
    private var genreViewControllers: [Int: GenreMoviesViewController] = [:]

    init(viewModel: IMovieExplorerViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setLayoutStyle() -> (top: EdgeLayoutStyle, leading: EdgeLayoutStyle, bottom: EdgeLayoutStyle, trailing: EdgeLayoutStyle) {
        return (.safeArea, .superview, .superview, .superview)
    }
    
    override func setupView() {
        self.title = "Keşfet"
        rootView.pageViewController.dataSource = self
        rootView.pageViewController.delegate = self
    }
    
    override func initialComponents() {
        observeViewState()
        listenErrorState()
        viewModel.fetchInitialData()
    }
    
    private func observeViewState() {
        viewModel.viewState
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.handle(state: state) }
            .store(in: &cancelBag)
    }
    
    private func handle(state: MovieExplorerViewState) {
        switch state {
        case .initialLoading:
            rootView.showInitialLoading(true)
        case .genresLoaded:
            rootView.showInitialLoading(false)
            setupInitialPage()
        case .moviesLoading(let genreId):
            genreViewControllers[genreId]?.showLoading()
        case .moviesLoaded(let genreId, let movies, let initialOffset):
            genreViewControllers[genreId]?.update(with: movies, initialOffset: initialOffset)
        }
    }
    
    private func listenErrorState() {
        viewModel.errorState
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                print("Error: \(errorMessage)")
                self?.rootView.showInitialLoading(false)
            }
            .store(in: &cancelBag)
    }

    private func setupInitialPage() {
        guard let firstGenre = viewModel.genres.first else { return }
        let firstVC = viewController(for: firstGenre.id)
        rootView.setInitialPage(viewController: firstVC)
        updateNavigationTitle(for: firstGenre.id)
    }
    
    private func viewController(for genreId: Int) -> GenreMoviesViewController {
        if let existingVC = genreViewControllers[genreId] { return existingVC }
        let newVC = GenreMoviesViewController(genreId: genreId)
        newVC.onRequiresNextPage = { [weak self] in self?.viewModel.loadNextPage() }
        genreViewControllers[genreId] = newVC
        return newVC
    }
}

private extension MovieExplorerViewController {
    func updateNavigationTitle(for genreId: Int) {
        if let genre = viewModel.genres.first(where: { $0.id == genreId }) {
            self.title = genre.name
        }
    }
}

extension MovieExplorerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? GenreMoviesViewController,
              let currentIndex = viewModel.genres.firstIndex(where: { $0.id == currentVC.genreId }),
              currentIndex > 0 else { return nil }
        return self.viewController(for: viewModel.genres[currentIndex - 1].id)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? GenreMoviesViewController,
              let currentIndex = viewModel.genres.firstIndex(where: { $0.id == currentVC.genreId }),
              currentIndex < viewModel.genres.count - 1 else { return nil }
        return self.viewController(for: viewModel.genres[currentIndex + 1].id)
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
