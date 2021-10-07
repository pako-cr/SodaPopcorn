//
//  Coordinator.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 19/9/21.
//

import Foundation
import UIKit

protocol Coordinator {
	var childCoordinators: [Coordinator] { get set }
	func start()
}
