//
//  GenreMoviesViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import UIKit

final class GenreMoviesViewController: AlfaBaseViewController<GenreMoviesRootView> {
    
    let genreId: Int
    private var movies: [DiscoverResultUIModel] = []
    var onRequiresNextPage: (() -> Void)?
    private var isLoadingNextPage = false

    var currentContentOffset: CGPoint { rootView.collectionView.contentOffset }

    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>!

    init(genreId: Int) {
        self.genreId = genreId
        super.init()
    }

    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func initialComponents() {
        super.initialComponents()
        rootView.collectionView.delegate = self
        setupDataSource()
    }
    
    func update(with movies: [DiscoverResultUIModel], initialOffset: CGPoint) {
        self.movies = movies
        self.isLoadingNextPage = false
        rootView.showLoading(false)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: true)

        if initialOffset != .zero && rootView.collectionView.contentSize.height > rootView.collectionView.bounds.height {
             DispatchQueue.main.async { [weak self] in
                 self?.rootView.collectionView.setContentOffset(initialOffset, animated: false)
             }
        }
    }
    
    func showLoading() {
        if movies.isEmpty { rootView.showLoading(true) }
    }
    
    private func setupDataSource() {
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

extension GenreMoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item >= movies.count - 4 && !isLoadingNextPage {
            isLoadingNextPage = true
            onRequiresNextPage?()
        }
    }
}
