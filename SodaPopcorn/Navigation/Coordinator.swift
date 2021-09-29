//
//  Coordinator.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 19/9/21.
//

import Foundation
import UIKit

protocol Coordinator {
	var childCoordinators: [Coordinator] { get set }
	var navigationController: UINavigationController { get set }
	func start()
}
