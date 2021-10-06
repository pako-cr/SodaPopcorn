//
//  MovieListCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 13/9/21.
//

import UIKit

final class MovieListCollectionViewCell: UICollectionViewCell {
	// MARK: Constants
	static let reuseIdentifier = "movieListCollectionViewCellId"
	private var viewModel: PosterImageViewModel?

	// MARK: Variables
	private var movie: Movie? {
		didSet {
			guard let movie = movie else { return }

			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }

				if let posterImage = movie.posterImageData {
					self.posterImage.image = UIImage(data: posterImage)
				} else {
					self.viewModel?.getPosterImage(movie: movie, posterPath: movie.posterPath ?? "", completion: { [weak self] imageData, error in
						if error != nil {
							DispatchQueue.main.async { [weak self] in
								guard let `self` = self else { return }
								self.posterImage.image = UIImage(named: "no_poster")
							}
						}

						guard let data = imageData else { return }

						DispatchQueue.main.async { [weak self] in
							guard let `self` = self else { return }
							self.posterImageIndicatorView.stopAnimating()
							self.posterImage.image = UIImage(data: data)

//							let accessibilityLabelFormatString = NSLocalizedString("movie_list_collection_view_cell_poster_image_label", comment: "")
//							self.posterImage.accessibilityLabel = String.localizedStringWithFormat(accessibilityLabelFormatString, self.movie?.title ?? "")
						}
					})
				}

				self.movieTitle.text = movie.title
				self.ratingLabel.text = movie.rating?.description ?? "0.0"
				self.movieOverview.text = movie.overview != "" ? movie.overview : NSLocalizedString("movie_list_collection_view_cell_no_overview_found", comment: "")

				self.sizeToFit()
			}
		}
	}

	// MARK: UI Elements
	private let activityIndicatorView: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.startAnimating()
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		return activityIndicator
	}()

	private let separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.gray
		view.alpha = 0.4
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let posterImageIndicatorView: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.startAnimating()
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		return activityIndicator
	}()

	private let posterImage: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleToFill

		return imageView
	}()

	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .leading
		stackView.distribution = .fillProportionally
		stackView.axis = .horizontal
		stackView.spacing = 5
		return stackView
	}()

	private let movieTitle: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 2
		label.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: .horizontal)
		return label
	}()

	private let ratingLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
		label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
		return label
	}()

	private let movieOverview: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 6
		label.font = UIFont.preferredFont(forTextStyle: .caption1)
		label.textAlignment = .justified
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
		addSubview(activityIndicatorView)

		activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		activityIndicatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		activityIndicatorView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		posterImage.addSubview(posterImageIndicatorView)

		posterImageIndicatorView.centerXAnchor.constraint(equalTo: posterImage.centerXAnchor).isActive = true
		posterImageIndicatorView.centerYAnchor.constraint(equalTo: posterImage.centerYAnchor).isActive = true
		posterImageIndicatorView.widthAnchor.constraint(equalTo: posterImage.widthAnchor).isActive = true
		posterImageIndicatorView.heightAnchor.constraint(equalTo: posterImage.heightAnchor).isActive = true

		stackView.addArrangedSubview(movieTitle)
		stackView.addArrangedSubview(ratingLabel)

		addSubview(separatorView)
		addSubview(posterImage)
		addSubview(stackView)
		addSubview(movieOverview)

		separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

		posterImage.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
		posterImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
		posterImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25).isActive = true
		posterImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true

		stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
		stackView.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10).isActive = true
		stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
		stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true

		movieOverview.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: 5).isActive = true
		movieOverview.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10).isActive = true
		movieOverview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
		movieOverview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
	}

	func configure(with data: Movie?, and viewModel: PosterImageViewModel?) {
		activityIndicatorView.stopAnimating()
		self.movie = data
		self.viewModel = viewModel
	}

	// MARK: - 🗑 Deinit
	deinit {
//		print("🗑 MovieListCollectionViewCell deinit.")
	}
}
