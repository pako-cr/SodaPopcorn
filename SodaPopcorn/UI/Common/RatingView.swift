//
//  RatingView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import Foundation
import UIKit

public final class RatingView: UIView {

    // MARK: - UI Elements
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .subheadline).bold()
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = false
        label.text = "0.0"
        label.sizeToFit()
        return label
    }()

    public init(ratingValue: Double) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers
    private func getStrokeColor(percentage: Double) -> UIColor {
        switch percentage {
        case 0.51...0.70:
            return UIColor.yellow
        case 0.70...1.0:
            return UIColor.systemGreen
        default:
            return UIColor.red
        }
    }

    func setRatingValue(ratingValue: Double) {
        ratingLabel.text = String(Double(ratingValue).description.prefix(3))
        setupCircleShape(ratingValue: ratingValue * 0.1)
    }

    private func setupCircleShape(ratingValue: Double) {
        let roundView = UIView(frame: CGRect(x: .zero, y: .zero, width: bounds.width, height: bounds.width))
        let roundViewBackgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
        roundView.backgroundColor = roundViewBackgroundColor
        roundView.layer.cornerRadius = roundView.frame.size.width / 2
        roundView.sizeToFit()

        // Full circle
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: roundView.frame.size.width / 2, y: roundView.frame.size.height / 2),
                                      radius: roundView.frame.size.width / 2,
                                      startAngle: CGFloat(-0.5 * Double.pi),
                                      endAngle: CGFloat(1.5 * Double.pi),
                                      clockwise: true)
        // circle shape
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        circleShape.strokeColor = UIColor.systemGray2.cgColor
        circleShape.fillColor = UIColor.clear.cgColor
        circleShape.lineWidth = 5.0
        circleShape.strokeStart = 0.0
        circleShape.strokeEnd = 1.0

        // circle shape 2
        let circleShape2 = CAShapeLayer()
        circleShape2.path = circlePath.cgPath
        circleShape2.strokeColor = getStrokeColor(percentage: ratingValue).cgColor
        circleShape2.fillColor = UIColor.clear.cgColor
        circleShape2.lineWidth = 2.0
        circleShape2.strokeStart = 0.0
        circleShape2.strokeEnd = ratingValue

        // add sublayer
        roundView.layer.addSublayer(circleShape)
        roundView.layer.addSublayer(circleShape2)

        addSubview(roundView)
        addSubview(ratingLabel)

        ratingLabel.centerXAnchor.constraint(equalTo: roundView.centerXAnchor).isActive = true
        ratingLabel.centerYAnchor.constraint(equalTo: roundView.centerYAnchor).isActive = true
        ratingLabel.widthAnchor.constraint(equalTo: roundView.widthAnchor).isActive = true
        ratingLabel.heightAnchor.constraint(equalTo: roundView.heightAnchor).isActive = true
    }
}
