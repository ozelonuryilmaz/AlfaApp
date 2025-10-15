//
//  MovieExplorerRootView.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit

// MARK: View Interface
protocol MovieExplorerRootViewDelegate: AnyObject {
    
    //func favoriteViewDidTapCapture()
}

// MARK: View Implementation
final class MovieExplorerRootView: BaseRootView {
    
    weak var delegate: MovieExplorerRootViewDelegate?
    
    // MARK: Init
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupUI()
    }
    
    // MARK: Definitions
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Başlık"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Devam", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteViewDidTapCapture), for: .touchUpInside)
        return button
    }()
}

// MARK: Setup
private extension MovieExplorerRootView {
    
    func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

// MARK:  Button Tapped
@objc private extension MovieExplorerRootView {
    
    func favoriteViewDidTapCapture() {
        //delegate?.favoriteViewDidTapCapture()
    }
}


// MARK: IMovieExplorerRootView
extension MovieExplorerRootView {
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}
