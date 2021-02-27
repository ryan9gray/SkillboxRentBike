//
//  UIView.swift
//  SkillBoxTester
//
//  Created by Evgeny Ivanov on 13.08.2020.
//  Copyright © 2020 Evgeny Ivanov. All rights reserved.
//

import UIKit

public extension UIView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    private static func loadNib<T: UIView>(
        name: String,
        bundle: Bundle,
        owner: Any?,
        options: [UINib.OptionsKey: Any]?
    ) -> T {
        guard let nibContent = bundle.loadNibNamed(name, owner: owner, options: options) else {
            fatalError("Cannot load nib with name \(name).")
        }

        guard let firstObject = nibContent.first else {
            fatalError("Cannot get first object from \(name) nib.")
        }

        guard let view = firstObject as? T else {
            fatalError("Invalid \(name) nib view type. Expected \(T.self), but received \(type(of: firstObject))")
        }

        return view
    }

    class func fromNib(
        name: String? = nil,
        bundle: Bundle? = nil,
        owner: Any? = nil,
        options: [UINib.OptionsKey: Any]? = nil
    ) -> Self {
        return loadNib(name: name ?? String(describing: self), bundle: bundle ?? Bundle(for: self), owner: owner, options: options)
    }

    func minSize(thatFits size: CGSize) -> CGSize {
        let oldSize = size
        defer { frame.size = oldSize }
        frame.size = size
        return systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
