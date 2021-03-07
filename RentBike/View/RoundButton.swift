//
//  RoundButton.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 07.03.2021.
//

import UIKit

@IBDesignable
class RoundEdgeButton: UIButton {

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColorFromUIcolor
        }
        set {
            layer.borderColorFromUIcolor = newValue
        }
    }

    @IBInspectable var roundCoefficient: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * roundCoefficient
    }

}
extension CALayer {
    var borderColorFromUIcolor: UIColor? {
        get {
            if let borderColor = borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
        set {
            borderColor = newValue?.cgColor
        }
    }
}
