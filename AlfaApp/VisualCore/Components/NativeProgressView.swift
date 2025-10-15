//
//  NativeProgressView.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import UIKit

final class NativeProgressView: BaseReusableView {

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    override func initializeSelf() {
        alpha = 0
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupViews()
    }

    func playAnimation(isPlay: Bool) {
        if isPlay {
            playAnimation()
        } else {
            stopAnimation()
        }
    }

    func playAnimation(isPlay: Bool, parentView: UIView?) {
        if isPlay {
            playAnimation(parentView: parentView)
        } else {
            stopAnimation()
        }
    }

    func playAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let window = WindowHelper.getWindow() else { return }

            if !self.activityIndicator.isAnimating {
                window.addSubview(self)
                self.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    self.topAnchor.constraint(equalTo: window.topAnchor),
                    self.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                    self.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                    self.trailingAnchor.constraint(equalTo: window.trailingAnchor)
                ])

                window.bringSubviewToFront(self)
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1.0
                }
                self.activityIndicator.startAnimating()
            }
        }
    }

    func playAnimation(parentView: UIView?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let parentView = parentView else { return }

            if !self.activityIndicator.isAnimating {
                parentView.addSubview(self)
                self.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    self.topAnchor.constraint(equalTo: parentView.topAnchor),
                    self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                    self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                    self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
                ])

                parentView.bringSubviewToFront(self)
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1.0
                }
                self.activityIndicator.startAnimating()
            }
        }
    }

    func stopAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.activityIndicator.isAnimating {
                UIView.animate(withDuration: 0.1, animations: {
                    self.alpha = 0
                }, completion: { _ in
                    self.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }

    private func setupViews() {
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

