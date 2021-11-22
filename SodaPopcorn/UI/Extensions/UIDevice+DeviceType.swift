//
//  UIDevice+DeviceType.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 21/11/21.
//

import UIKit

extension UIDevice {
    var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
