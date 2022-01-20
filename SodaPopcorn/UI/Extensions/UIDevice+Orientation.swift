//
//  UIDevice+Orientation.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba Zimplifica on 3/12/21.
//

import UIKit

extension UIDevice {
    static var isLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }
}
