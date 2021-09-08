//
//  MovieListViewController.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 5/9/21.
//

import Combine
import UIKit

final class MovieListViewController: UIViewController {
	// MARK: - Consts
	private let viewModel: MovieListViewModel
	private let posterImageViewModel = PosterImageViewModel()

	// MARK: - Variables
	private var cancellable = Set<AnyCancellable>()
	private var dataSource: [Movie] = [] {
		didSet {
			DispatchQueue.main.async { [weak self] in
				print("🔸 Reloading datasource!")
				self?.collectionView.reloadData()
			}
		}
	}

	// MARK: - UI Elements
	private var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(MovieListCollectionViewCell.self, forCellWithReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isScrollEnabled = true
		collectionView.allowsSelection = true
		return collectionView
	}()

	init(viewModel: MovieListViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		bindViewModel()
		viewModel.inputs.viewDidLoad()
    }

	override func viewWillLayoutSubviews() {
		collectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .clear
	}

	private func setupUI() {
		navigationItem.title = "SodaPopcorn 🍿"
		view.addSubview(collectionView)

		collectionView.dataSource = self
		collectionView.delegate = self

		collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

	private func bindViewModel() {
		viewModel.outputs.fetchNewMoviesAction()
			.sink(receiveValue: { [weak self] (movies) in
				guard let `self` = self, let movies = movies else { return }
				self.dataSource = movies
			}).store(in: &cancellable)

		posterImageViewModel.outputs.fetchPosterImageSignal()
			.sink(receiveValue: { [weak self] (movieInfo) in
				guard let `self` = self else { return }
				self.setPosterImageData(movieId: movieInfo.0, imageData: movieInfo.1)
			}).store(in: &cancellable)
	}

	// MARK: - ⚙️ Helpers
	private func setPosterImageData(movieId: Int, imageData: Data) {
		if let index = self.dataSource.firstIndex(where: { $0.id == movieId }) {
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				self.dataSource[index].posterImageData = imageData
			}
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 MovieListViewController deinit.")
	}
}

extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataSource.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieListCollectionViewCell {
			cell.movie = dataSource[indexPath.item]
			cell.viewModel = posterImageViewModel
			return cell
		}

		return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCellId", for: indexPath)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height / 5)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
}

final class MovieListCollectionViewCell: UICollectionViewCell {
	// MARK: Constants
	static let reuseIdentifier = "MovieListCollectionViewCellId"
	var viewModel: PosterImageViewModel?

	// MARK: Variables
	var movie: Movie? {
		didSet {
			guard let movie = movie else { return }

			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }

				if let posterImage = movie.posterImageData {
					self.posterImage.image = UIImage(data: posterImage)
				} else {
					self.viewModel?.getPosterImage(movieId: movie.id, posterPath: movie.posterPath, completion: { [weak self] imageData, _ in
						guard let data = imageData else { return }
						DispatchQueue.main.async { [weak self] in
							guard let `self` = self else { return }
							self.posterImage.image = UIImage(data: data)
						}
					})
				}

				self.movieTitle.text = movie.title
				self.ratingLabel.text = movie.rating.description
				self.movieOverview.text = movie.overview

				self.sizeToFit()
			}
		}
	}

	// MARK: UI Elements
	private let separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.gray
		view.alpha = 0.4
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let posterImage: UIImageView = {
		let image = UIImage(named: "no_poster")

		let imageView = UIImageView(image: image)
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

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 MovieListCollectionViewCell deinit.")
	}
}
