//
//  MovieExplorerRootView.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//  Copyright (c) 2025 AlfaApp IOS Development Team. All rights reserved.
//

import UIKit

final class MovieExplorerRootView: BaseRootView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showInitialLoading(_ isLoading: Bool) {
        if isLoading { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }
    
    func setInitialPage(viewController: UIViewController) {
        pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: Definitions
    
    private(set) var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
}

// MARK: Setup
private extension MovieExplorerRootView {
    
    func setupUI() {
        addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: self.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
