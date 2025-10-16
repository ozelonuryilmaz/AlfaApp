//
//  MovieExplorerViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit

final class MovieExplorerViewController: AlfaBaseViewController<MovieExplorerRootView> {
    
    // MARK: Typealiases for DiffableDataSource
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieItemViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieItemViewModel>

    private enum Section {
        case main
    }
    
    // MARK: Properties
    private let viewModel: IMovieExplorerViewModel
    private var dataSource: DataSource!
    
    private var scrollPositionCache = [Int: CGPoint]()
    private var currentGenreId: Int?
    private var isTransitioning = false
    private var lastSwipeDirection: SwipeDirection = .next

    // MARK: Init
    init(viewModel: IMovieExplorerViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: Lifecycle
    override func setupView() {
        super.setupView()
        configureCollectionView()
        configureDataSource()
        addSwipeRecognizers()
    }
    
    override func initialComponents() {
        observeViewState()
        listenErrorState()
        viewModel.initialLoad()
    }
    
    // MARK: Configuration
    private func configureCollectionView() {
        rootView.moviesCollectionView.setCollectionViewLayout(createLayout(), animated: false)
        rootView.moviesCollectionView.register(MoviePosterCell.self, forCellWithReuseIdentifier: MoviePosterCell.reuseIdentifier)
        rootView.moviesCollectionView.prefetchDataSource = self
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: rootView.moviesCollectionView, cellProvider: { collectionView, indexPath, itemViewModel in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCell.reuseIdentifier, for: indexPath) as? MoviePosterCell else {
                fatalError("Cannot create new cell")
            }
            cell.configure(with: itemViewModel.movie)
            return cell
        })
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(12)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 16
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: Actions
    @objc private func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        guard !isTransitioning else { return }
        
        if sender.direction == .left {
            self.lastSwipeDirection = .next
            viewModel.didSwipe(direction: .next)
        } else if sender.direction == .right {
            self.lastSwipeDirection = .previous
            viewModel.didSwipe(direction: .previous)
        }
    }
    
    private func addSwipeRecognizers() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:))); left.direction = .left
        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:))); right.direction = .right
        rootView.moviesCollectionView.addGestureRecognizer(left)
        rootView.moviesCollectionView.addGestureRecognizer(right)
    }
    
    // MARK: Bindings
    private func observeViewState() {
        viewModel.viewState.compactMap { $0 }.receive(on: DispatchQueue.main).sink { [weak self] state in
            self?.handle(state: state)
        }.store(in: &cancelBag)
    }
    
    private func handle(state: MovieExplorerViewState) {
        switch state {
        case .showLoading(let isProgress):
            if isProgress && (dataSource.snapshot().itemIdentifiers.isEmpty) { playNativeLoading(isLoading: true) }
            else { playNativeLoading(isLoading: false) }
            
        case .display(let genreId, let genreTitle, let movies):
            let isCategoryChange = self.currentGenreId != nil && self.currentGenreId != genreId
            if isCategoryChange {
                performTransitionAnimation(swipeDirection: self.lastSwipeDirection, genreId: genreId, genreTitle: genreTitle, newItems: movies)
            } else {
                self.currentGenreId = genreId
                rootView.setTitle(genreTitle)
                applySnapshot(with: movies, isCategoryChange: false)
            }
            
        case .showPaginationLoading: break
        }
    }

    private func performTransitionAnimation(swipeDirection: SwipeDirection, genreId: Int, genreTitle: String, newItems: [MovieItemViewModel]) {
        guard let oldGenreId = self.currentGenreId, let oldSnapshot = rootView.moviesCollectionView.snapshotView(afterScreenUpdates: false) else { return }
        isTransitioning = true
        
        scrollPositionCache[oldGenreId] = rootView.moviesCollectionView.contentOffset
        oldSnapshot.frame = rootView.moviesCollectionView.frame
        rootView.addSubview(oldSnapshot)
        
        rootView.moviesCollectionView.isHidden = true
        self.currentGenreId = genreId
        rootView.setTitle(genreTitle)
        applySnapshot(with: newItems, isCategoryChange: true)
        
        if let pos = scrollPositionCache[genreId] { rootView.moviesCollectionView.setContentOffset(pos, animated: false) }
        else { rootView.moviesCollectionView.setContentOffset(.zero, animated: false) }
        
        rootView.moviesCollectionView.layoutIfNeeded()
        guard let newSnapshot = rootView.moviesCollectionView.snapshotView(afterScreenUpdates: true) else { return }
        newSnapshot.frame = rootView.moviesCollectionView.frame
        
        let direction: CGFloat = (swipeDirection == .next) ? 1.0 : -1.0
        let offset = rootView.bounds.width * direction
        newSnapshot.transform = CGAffineTransform(translationX: offset, y: 0)
        rootView.addSubview(newSnapshot)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            oldSnapshot.transform = CGAffineTransform(translationX: -offset, y: 0)
            oldSnapshot.alpha = 0.5
            newSnapshot.transform = .identity
        }) { _ in
            self.rootView.moviesCollectionView.isHidden = false
            oldSnapshot.removeFromSuperview()
            newSnapshot.removeFromSuperview()
            self.isTransitioning = false
        }
    }

    private func applySnapshot(with items: [MovieItemViewModel], isCategoryChange: Bool) {
        var snapshot = Snapshot(); snapshot.appendSections([.main]); snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: !isCategoryChange)
    }

    private func listenErrorState() {
        viewModel.errorState.receive(on: DispatchQueue.main).sink { errorMessage in
            print("Hata Alındı: \(errorMessage)") // Alert gösterilebilir.
        }.store(in: &cancelBag)
    }
}

// MARK: UICollectionViewDataSourcePrefetching
extension MovieExplorerViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let currentCount = dataSource.snapshot().numberOfItems(inSection: .main)
        if indexPaths.contains(where: { $0.row >= (currentCount - 5) }) {
            viewModel.loadMoreMovies()
        }
    }
}
