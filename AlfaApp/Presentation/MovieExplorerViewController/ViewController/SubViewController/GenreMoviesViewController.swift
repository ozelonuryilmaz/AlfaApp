//
//  GenreMoviesViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import UIKit

final class GenreMoviesViewController: AlfaBaseViewController<GenreMoviesRootView> {
    
    let genreId: Int
    var onRequiresNextPage: (() -> Void)?
    var onMovieTapped: ((_ movie: DiscoverResultUIModel) -> Void)?
    var currentContentOffset: CGPoint { rootView.collectionView.contentOffset }
    
    private var movies: [DiscoverResultUIModel] = []
    private var isLoadingNextPage = false
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    
    init(genreId: Int) {
        self.genreId = genreId
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialComponents() {
        super.initialComponents()
        rootView.collectionView.delegate = self
        setupDataSource()
    }
    
    func showLoading() {
        if movies.isEmpty { rootView.showLoading(true) }
    }
}


// MARK: Setup
private extension GenreMoviesViewController {
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MoviePosterCell, Int> { [weak self] (cell, indexPath, itemId) in
            guard let movie = self?.movies.first(where: { $0.id == itemId }) else { return }
            cell.configure(with: movie)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: rootView.collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemId: Int) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemId)
        }
    }
}


// MARK: Update
extension GenreMoviesViewController {
    
    func update(with movies: [DiscoverResultUIModel], initialOffset: CGPoint, isPagination: Bool) {
        self.movies = movies
        self.isLoadingNextPage = false
        rootView.showLoading(false)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: isPagination)
        
        if !isPagination && initialOffset != .zero && rootView.collectionView.contentSize.height > rootView.collectionView.bounds.height {
            DispatchQueue.main.async { [weak self] in
                self?.rootView.collectionView.setContentOffset(initialOffset, animated: false)
            }
        }
    }
}


// MARK: User Actions
private extension GenreMoviesViewController {
    
    func handleMovieSelection(at indexPath: IndexPath) {
        guard let tappedMovieId: Int = dataSource.itemIdentifier(for: indexPath),
              let tappedMovie: DiscoverResultUIModel = self.movies.first(where: { $0.id == tappedMovieId }) else { return }
        onMovieTapped?(tappedMovie)
    }
}


// MARK: UICollectionViewDelegate
extension GenreMoviesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item >= movies.count - 4 && !isLoadingNextPage {
            isLoadingNextPage = true
            onRequiresNextPage?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleMovieSelection(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let identifier = indexPath as NSIndexPath
            
            return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
                guard let self = self else { return UIMenu(title: "", children: []) }
                let watchAction = UIAction(title: L10n.watch, image: UIImage(systemName: "play.fill") ) { _ in
                    self.handleMovieSelection(at: indexPath)
                }
                return UIMenu(title: "", children: [watchAction])
            }
        }
}
