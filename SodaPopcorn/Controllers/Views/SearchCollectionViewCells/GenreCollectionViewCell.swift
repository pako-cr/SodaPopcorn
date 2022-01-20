//
//  GenreCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 16/11/21.
//

import UIKit

final class GenreCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "genreCollectionViewCellId"

    // MARK: Variables
    private var imageViewCenterYLayoutConstraint: NSLayoutConstraint?
    private var parallaxOffset: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.imageViewCenterYLayoutConstraint?.constant = self.parallaxOffset
            }
        }
    }

    private var genre: Genre? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let genre = self.genre else { return }

                self.genreName.text = genre.name ?? ""

                var image = UIImage()
                switch genre.id {
                case 28:
                    if let assetImage = UIImage(named: "action_genre_backdrop") { image = assetImage }
                case 12:
                    if let assetImage = UIImage(named: "adventure_genre_backdrop") { image = assetImage }
                case 16:
                    if let assetImage = UIImage(named: "animation_genre_backdrop") { image = assetImage }
                case 35:
                    if let assetImage = UIImage(named: "comedy_genre_backdrop") { image = assetImage }
                case 80:
                    if let assetImage = UIImage(named: "crime_genre_backdrop") { image = assetImage }
                case 99:
                    if let assetImage = UIImage(named: "documentary_genre_backdrop") { image = assetImage }
                case 10751:
                    if let assetImage = UIImage(named: "family_genre_backdrop") { image = assetImage }
                case 27:
                    if let assetImage = UIImage(named: "horror_genre_backdrop") { image = assetImage }
                case 10402:
                    if let assetImage = UIImage(named: "music_genre_backdrop") { image = assetImage }
                case 9648:
                    if let assetImage = UIImage(named: "mystery_genre_backdrop") { image = assetImage }
                case 10749:
                    if let assetImage = UIImage(named: "romance_genre_backdrop") { image = assetImage }
                case 878:
                    if let assetImage = UIImage(named: "science_fiction_genre_backdrop") { image = assetImage }
                case 10770:
                    if let assetImage = UIImage(named: "tv_movie_genre_backdrop") { image = assetImage }
                case 53:
                    if let assetImage = UIImage(named: "thriller_genre_backdrop") { image = assetImage }
                case 10752:
                    if let assetImage = UIImage(named: "war_genre_backdrop") { image = assetImage }
                case 37:
                    if let assetImage = UIImage(named: "western_genre_backdrop") { image = assetImage }
                case 36:
                    if let assetImage = UIImage(named: "history_genre_backdrop") { image = assetImage }
                case 18:
                    if let assetImage = UIImage(named: "drama_genre_backdrop") { image = assetImage }
                case 14:
                    if let assetImage = UIImage(named: "fantasy_genre_backdrop") { image = assetImage }
                default:
                    if let assetImage = UIImage(named: "no_backdrop") { image = assetImage }
                }

                self.genreImage.image = image
            }
        }
    }

    // MARK: UI Elements
    private let genreImage = CustomBackdropImage(activityIndicatorEnabled: false)

    private lazy var genreName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        layer.masksToBounds = true

        addSubview(genreImage)
        addSubview(genreName)

        imageViewCenterYLayoutConstraint = genreImage.centerYAnchor.constraint(equalTo: centerYAnchor)
        imageViewCenterYLayoutConstraint?.isActive = true

        genreImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.5).isActive = true
        genreImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        genreImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        genreImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        genreName.topAnchor.constraint(equalTo: topAnchor).isActive = true
        genreName.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        genreName.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        genreName.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: Helpers
    func configure(with genre: Genre) {
        self.genre = genre
    }

    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
        let maxVerticalOffset = (bounds.height / 2) + self.bounds.height / 2
        let scaleFactor = 40 / maxVerticalOffset
        parallaxOffset = offsetFromCenter.y * scaleFactor
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 GenreCollectionViewCell deinit.")
    }
}
