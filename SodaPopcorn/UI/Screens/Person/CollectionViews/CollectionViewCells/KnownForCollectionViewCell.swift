//
//  KnownForCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import UIKit

final class KnownForCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "knownForCollectionViewCellId"

    // MARK: Variables
    private var movie: Movie? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let movie = self.movie else { return }

                if movie.title == "more_info" {
                    self.posterImage.isHidden = true
                    self.movieName.isHidden = true
                    self.characterName.isHidden = true
                    self.layer.borderWidth = 1
                    self.layer.borderColor = UIColor(named: "PrimaryColor")?.cgColor
                    self.layer.cornerRadius = 10

                    self.setEmptyView(title: NSLocalizedString("more_info", comment: "More info"), centered: true)

                } else {
                    self.removeEmptyView()
                    self.posterImage.isHidden = false
                    self.movieName.isHidden = false
                    self.characterName.isHidden = false
                    self.layer.borderWidth = 0
                    self.layer.borderWidth = 1
                    self.layer.borderColor = UIColor.clear.cgColor

                    if let posterPath = movie.posterPath {
                        self.posterImage.setUrlString(urlString: posterPath)
                    } else {
                        self.posterImage.image = UIImage(named: "no_poster")
                    }

                    if let movieName = movie.title {
                        self.movieName.text = movieName
                    }

                    if let movieCharacter = movie.character {
                        self.characterName.text = movieCharacter
                    }
                }
            }
        }
    }

    // MARK: UI Elements
    private let posterImage = CustomPosterImage(frame: .zero)

    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let movieName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1).bold()
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
        return label
    }()

    private let characterName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
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
        addSubview(posterImage)
        addSubview(mainStack)

        mainStack.addArrangedSubview(movieName)
        mainStack.addArrangedSubview(characterName)

        posterImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        posterImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        posterImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        posterImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true

        mainStack.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 2.0).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    }

    // MARK: Helpers
    func configure(with movie: Movie?) {
        self.movie = movie
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 KnownForCollectionViewCell deinit.")
    }
}
