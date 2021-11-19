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
                self.genreImage.alpha = 0.75
            }
        }
    }

    // MARK: UI Elements
    private let genreImage = CustomBackdropImage(activityIndicatorEnabled: false)

    private lazy var genreName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = self.traitCollection.userInterfaceStyle == .light ? .preferredFont(forTextStyle: .title3).bold() : .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        genreName.font = traitCollection.userInterfaceStyle == .light ? .preferredFont(forTextStyle: .title3).bold() : .preferredFont(forTextStyle: .headline)
    }

    func setupCellView() {
        addSubview(genreImage)
        addSubview(genreName)

        genreImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        genreImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        genreImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        genreImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        genreName.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        genreName.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        genreName.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        genreName.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9).isActive = true
    }

    // MARK: Helpers
    func configure(with genre: Genre) {
        self.genre = genre
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 GenreCollectionViewCell deinit.")
    }
}
