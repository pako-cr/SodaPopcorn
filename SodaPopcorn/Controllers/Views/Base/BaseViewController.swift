//
//  BaseViewController.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/9/21.
//

import UIKit

class BaseViewController: UIViewController {

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		bindViewModel()
        tabBarController?.tabBar.backgroundColor = UIColor.systemBackground
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
    }

	func setupUI() {
	}

	func bindViewModel() {
	}

    func setupNavigationBar() {
    }
}
