//
//  UISearchBar+ActivityIndicator.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 18/11/21.
//

import UIKit

extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
           if let textField = value(forKey: "searchField") as? UITextField {
                return textField
            }
            return nil
        }
    }

    private var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }

    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                DispatchQueue.main.async {
                    if self.activityIndicator == nil {
                        let newActivityIndicator = UIActivityIndicatorView(style: .medium)
                        newActivityIndicator.startAnimating()
                        if #available(iOS 13.0, *) {
                            newActivityIndicator.backgroundColor = UIColor.systemGroupedBackground
                        } else {
                            newActivityIndicator.backgroundColor = UIColor.groupTableViewBackground
                        }
                        newActivityIndicator.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.textField?.leftView?.addSubview(newActivityIndicator)
                        let leftViewSize = self.textField?.leftView?.frame.size ?? CGSize.zero
                        newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                    }
                }

            } else {
                DispatchQueue.main.async {
                    self.activityIndicator?.removeFromSuperview()
                }
            }
        }
    }
}
