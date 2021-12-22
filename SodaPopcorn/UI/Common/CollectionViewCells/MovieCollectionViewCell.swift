//
//  MovieCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/9/21.
//

import Domain
import UIKit

final class MovieCollectionViewCell: UICollectionViewCell {

    // MARK: Constants
	static let reuseIdentifier = "movieCollectionViewCellId"

	// MARK: Variables
	private var posterImageWidthAnchor: NSLayoutConstraint?
	private var posterImageLeadingAnchor: NSLayoutConstraint?
	private var posterImageCenterXAnchor: NSLayoutConstraint?

	private var movieTitleLeadingAnchor: NSLayoutConstraint?
	private var movieOverviewLeadingAnchor: NSLayoutConstraint?

	private var movie: Movie? {
		didSet {
			guard let movie = movie else { return }

			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }

				if let posterPath = movie.posterPath {
					self.posterImage.setUrlString(urlString: posterPath)
				}

                self.movieTitle.text = !(movie.title?.isEmpty ?? true)
                ? movie.title
                : NSLocalizedString("not_applicable", comment: "Not applicable")

                self.movieOverview.text = !(movie.overview?.isEmpty ?? true)
                ? movie.overview
                : NSLocalizedString("no_information", comment: "No information")

                self.releaseDateLabel.text = !(movie.releaseDate?.isEmpty ?? true)
                ? movie.releaseDate?
                    .split(separator: Character.init("-"), maxSplits: 1, omittingEmptySubsequences: true).first?.description ?? ""
                : ""

                if let rating = movie.rating, rating > 0.0 {
                    self.ratingLabel.text = "﹒ \(movie.rating ?? 0.0)/10"
                }}
		}
	}

	override func layoutSubviews() {
		if 0...(UIScreen.main.bounds.width / 3) ~= frame.width { // Columns
			self.handleCellLayoutChange(collectionLayout: .columns)

		} else if 0...(UIScreen.main.bounds.width) ~= frame.width { // List
			self.handleCellLayoutChange(collectionLayout: .list)
		}

		super.layoutSubviews()
	}

	// MARK: UI Elements
	private let separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.gray
		view.alpha = 0.4
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let posterImage = CustomPosterImage()

	private let movieTitle: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
		label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
		label.numberOfLines = 2
		label.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: .horizontal)
		label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
		return label
	}()

	private let movieOverview = CustomTextView()

    private let subHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let releaseDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .natural
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.text = ""
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .natural
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.text = ""
        label.textColor = UIColor.darkGray
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

		posterImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
		posterImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		posterImageWidthAnchor = posterImage.widthAnchor.constraint(equalToConstant: frame.width)
		posterImageCenterXAnchor = posterImage.centerXAnchor.constraint(equalTo: centerXAnchor)
		posterImageLeadingAnchor = posterImage.leadingAnchor.constraint(equalTo: leadingAnchor)

		posterImageWidthAnchor?.isActive = true
		posterImageLeadingAnchor?.isActive = false
		posterImageCenterXAnchor?.isActive = true
	}

	// MARK: Helpers
	func configure(with data: Movie?) {
		self.movie = data
	}

	private func handleCellLayoutChange(collectionLayout: CollectionLayout) {
		switch collectionLayout {
			case .list:

            posterImageWidthAnchor?.constant = frame.width * 0.25
            posterImageCenterXAnchor?.isActive = false
            posterImageLeadingAnchor?.isActive = true
            posterImage.contentMode = .scaleAspectFit

            subHeaderStack.addArrangedSubview(releaseDateLabel)
            subHeaderStack.addArrangedSubview(ratingLabel)

            addSubview(separatorView)
            addSubview(movieTitle)
            addSubview(subHeaderStack)
            addSubview(movieOverview)

            separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

            movieTitle.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10).isActive = true
            movieTitle.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10).isActive = true
            movieTitle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
            movieTitle.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true

            subHeaderStack.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: 0).isActive = true
            subHeaderStack.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10).isActive = true
            subHeaderStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
            subHeaderStack.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1).isActive = true

            movieOverview.topAnchor.constraint(equalTo: subHeaderStack.bottomAnchor).isActive = true
            movieOverview.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10).isActive = true
            movieOverview.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
            movieOverview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            movieOverview.isUserInteractionEnabled = false

			case .columns:
            separatorView.removeFromSuperview()
            movieTitle.removeFromSuperview()
            releaseDateLabel.removeFromSuperview()
            ratingLabel.removeFromSuperview()
            subHeaderStack.removeFromSuperview()
            movieOverview.removeFromSuperview()

            posterImageWidthAnchor?.constant = frame.width
            posterImageCenterXAnchor?.isActive = true
            posterImageLeadingAnchor?.isActive = false
            posterImage.contentMode = .scaleAspectFill
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
//		print("🗑 MovieCollectionViewCell deinit.")
	}
}
