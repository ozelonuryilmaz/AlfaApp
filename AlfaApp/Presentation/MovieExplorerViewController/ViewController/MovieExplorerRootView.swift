//
//  MovieExplorerRootView.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit

final class MovieExplorerRootView: BaseRootView {
    
    // MARK: UI Components
    private(set) lazy var genreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var moviesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: Init
    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        setupUI()
    }
    
    // MARK: UI Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(genreTitleLabel)
        addSubview(moviesCollectionView)
        
        NSLayoutConstraint.activate([
            genreTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            genreTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            genreTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            moviesCollectionView.topAnchor.constraint(equalTo: genreTitleLabel.bottomAnchor, constant: 16),
            moviesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            moviesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            moviesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setTitle(_ text: String) {
        genreTitleLabel.text = text
    }
}
