//
//  MoviePosterCell.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 16.10.2025.
//

import UIKit
import Kingfisher

final class MoviePosterCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MoviePosterCell"
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        titleLabel.alpha = 0.0
        gradientView.alpha = 0.0
        // transform = .identity
    }
    
    /* ContextMenu eklendiği için iptal edildi. Kullanımı değerlendirelecek
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5,
                           options: [.curveEaseOut, .allowUserInteraction], animations: {
                let scale: CGFloat = self.isHighlighted ? 0.96 : 1.0
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
                // self.alpha = self.isHighlighted ? 0.8 : 1.0
            })
        }
    }
    */
    
    func configure(with movie: DiscoverResultUIModel) {
        titleLabel.text = movie.title
        
        if let url = movie.posterURL {
            posterImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.16))],
                                        completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.titleLabel.alpha = 1.0
                    self.gradientView.alpha = 1.0
                case .failure:
                    self.titleLabel.alpha = 0.0
                    self.gradientView.alpha = 0.0
                }
            })
            // .fade ile resim yüklenince yumuşak bir geçişle görünsün. '.cacheOriginalImage' ile orjinal resim de cache'lenebilir.
        } else {
            posterImageView.image = nil
        }
    }
    
    // MARK: Definitions
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let gradientView: GradientView = {
        let view = GradientView()
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
        if let boldDescriptor = descriptor.withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: boldDescriptor, size: 0)
        } else {
            let fallbackFont = UIFont.preferredFont(forTextStyle: .footnote)
            label.font = UIFont.systemFont(ofSize: fallbackFont.pointSize, weight: .bold)
        }
        
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.alpha = 0.0
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}


// MARK: SetupUI
private extension MoviePosterCell {
    
    func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(titleLabel)
        
        
        // TODO: Constraint hatalarını kontrol etmeyi unutma -> AspectRatio eklendi
        
        
        let aspectRatioConstraint = posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5)
        aspectRatioConstraint.priority = .required
        
        let cellHeightConstraint = contentView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor)
        cellHeightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            aspectRatioConstraint,
            cellHeightConstraint,
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            gradientView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),
            gradientView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10)
        ])
    }
}


// MARK: GradientView
private final class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        let topColor = UIColor(white: 0, alpha: 0.62).cgColor
        let bottomColor = UIColor(white: 0, alpha: 0.92).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.2, 1.0]
        
        backgroundColor = .clear
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        clipsToBounds = true
    }
}
