//
//  MovieListCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/9/21.
//

import UIKit

final class MovieListCollectionViewCell: UICollectionViewCell {

    // MARK: Constants
	static let reuseIdentifier = "movieListCollectionViewCellId"

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
                : NSLocalizedString("movie_list_collection_view_cell_no_overview_found", comment: "")

				self.sizeToFit()
			}
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

	private let posterImage = CustomPosterImage(frame: .zero)

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

	private let movieOverview: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.font = UIFont.preferredFont(forTextStyle: .footnote)
        textView.textAlignment = .natural
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.adjustsFontForContentSizeCategory = true
        textView.maximumContentSizeCategory = .accessibilityMedium
        textView.sizeToFit()
        textView.textContainer.lineBreakMode = .byTruncatingTail
		return textView
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupCellView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupCellView() {
		addSubview(separatorView)
		addSubview(posterImage)
		addSubview(movieTitle)
		addSubview(movieOverview)

		separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

		posterImage.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
		posterImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		posterImageWidthAnchor = posterImage.widthAnchor.constraint(equalToConstant: frame.width * 0.25)
		posterImageCenterXAnchor = posterImage.centerXAnchor.constraint(equalTo: centerXAnchor)
		posterImageLeadingAnchor = posterImage.leadingAnchor.constraint(equalTo: leadingAnchor)

		posterImageWidthAnchor?.isActive = true
		posterImageLeadingAnchor?.isActive = true
		posterImageCenterXAnchor?.isActive = false

		movieTitle.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10).isActive = true
		movieTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
		movieTitle.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true
		movieTitleLeadingAnchor = movieTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: frame.width * 0.275)
		movieTitleLeadingAnchor?.isActive = true

		movieOverview.topAnchor.constraint(equalTo: movieTitle.bottomAnchor).isActive = true
		movieOverview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
		movieOverview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
		movieOverviewLeadingAnchor = movieOverview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: frame.width * 0.275)
		movieOverviewLeadingAnchor?.isActive = true
	}

	// MARK: Helpers
	func configure(with data: Movie?) {
		self.movie = data
	}

	private func handleCellLayoutChange(collectionLayout: CollectionLayout) {
		switch collectionLayout {
			case .list:
				movieTitle.isHidden = false
				movieOverview.isHidden = false
				movieTitleLeadingAnchor?.constant = frame.width * 0.275
				movieOverviewLeadingAnchor?.constant = frame.width * 0.275

				posterImageWidthAnchor?.constant = frame.width * 0.25
				posterImageCenterXAnchor?.isActive = false
				posterImageLeadingAnchor?.isActive = true
				posterImage.contentMode = .scaleAspectFit

				separatorView.isHidden = false

			case .columns:
				movieTitle.isHidden = true
				movieOverview.isHidden = true

				posterImageWidthAnchor?.constant = frame.width
				posterImageCenterXAnchor?.isActive = true
				posterImageLeadingAnchor?.isActive = false
				posterImage.contentMode = .scaleAspectFit

				separatorView.isHidden = true
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
//		print("🗑 MovieListCollectionViewCell deinit.")
	}
}
