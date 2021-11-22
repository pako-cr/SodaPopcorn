//
//  Alert.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 17/10/21.
//

import UIKit

struct Alert {
	private static func showBasicAlert(on viewController: UIViewController, with title: String, message: String, actions: [UIAlertAction]) {
		DispatchQueue.main.async {
			let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
			actions.forEach { alert.addAction($0) }
			viewController.present(alert, animated: true)
		}
	}

    private static func showBasicActionSheet(on viewController: UIViewController, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        var newActions = actions
        newActions.append(UIAlertAction(title: NSLocalizedString("alert_cancel_button", comment: "Cancel button"), style: .cancel, handler: nil))
        newActions.forEach { alert.addAction($0) }

        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

    private static func showBasicPopover(on viewController: UIViewController, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: NSLocalizedString("options", comment: "Options"), message: "", preferredStyle: .actionSheet)

        let popover = alert.popoverPresentationController

        popover?.sourceView = viewController.view
        popover?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 164, height: 164)

        var newActions = actions
        newActions.append(UIAlertAction(title: NSLocalizedString("alert_cancel_button", comment: "Cancel button"), style: .cancel, handler: nil))
        newActions.forEach { alert.addAction($0) }

        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

	/// Present an basic alert on the center of the screen.
	/// - Parameters:
	///     - viewController: The view controller to be presented in.
	///     - message: A message for the alert.
	///     - title: A title for the alert.
	static func showAlert(on viewController: UIViewController, title: String, message: String) {
		var actions: [UIAlertAction] = []
		actions.append(UIAlertAction(title: NSLocalizedString("close", comment: "Close button"), style: .default, handler: { _ in }))
		showBasicAlert(on: viewController, with: title, message: message, actions: actions)
	}

	/// Present an basic alert on the center of the screen with a callback handler.
	/// - Parameters:
	///     - viewController: The view controller to be presented in.
	///     - message: A message for the alert.
	///     - title: A title for the alert.
	///     - handler: A callback.
	static func showAlert(on viewController: UIViewController, title: String, message: String, handler: @escaping((UIAlertAction)) -> Void) {
		let completeAction = UIAlertAction(title: NSLocalizedString("continue", comment: "Continue button"), style: .default, handler: handler)
		let actions: [UIAlertAction] = [completeAction]
		showBasicAlert(on: viewController, with: title, message: message, actions: actions)
	}

    /// Present an basic action sheet alert with multiple options on the center of the screen with a callback handler.
    /// - Parameters:
    ///     - viewController: The view controller to be presented in.
    ///     - message: A message for the alert.
    ///     - title: A title for the alert.
    ///     - handler: A callback.
    static func showActionSheet(on viewController: UIViewController, actions: [UIAlertAction]) {
        if UIDevice.current.isIpad {
            showBasicPopover(on: viewController, actions: actions)
        } else {
            showBasicActionSheet(on: viewController, actions: actions)
        }
    }
}
