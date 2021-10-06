//
//  BaseViewController.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 13/9/21.
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
    }

	func setupUI() {
	}

	func bindViewModel() {

	}
}
