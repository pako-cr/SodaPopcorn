//
//  NavigationController.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 29/9/21.
//

import UIKit

public class NavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.isModalInPresentation = true
        self.modalPresentationCapturesStatusBarAppearance = true
        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.navigationBar.prefersLargeTitles = true
        self.setNavigationBarHidden(false, animated: true)
        self.navigationBar.isHidden = false
        self.navigationBar.barTintColor = UIColor.systemBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
