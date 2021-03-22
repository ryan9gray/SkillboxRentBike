

import UIKit

extension NSLayoutConstraint {
    public func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    @objc static func fillConstraints(view: UIView, in superview: UIView, margins: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        return [
            view.topAnchor.constraint(equalTo: superview.topAnchor, constant: margins.top),
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margins.left),
            superview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margins.bottom),
            superview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margins.right),
        ]
    }
    static func fill(view: UIView, in superview: UIView, margins: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate(fillConstraints(view: view, in: superview, margins: margins))
    }

    static func center(view: UIView, in superview: UIView, margins: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        return [
            view.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            view.topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor, constant: margins.top),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: margins.left),
            superview.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: margins.bottom),
            superview.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: margins.right),
        ]
    }

    static func fixWidth(view: UIView, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let identifier = "FixWidthConstraint"
        view.removeConstraints(view.constraints.filter { $0.identifier == identifier })

        let width = NSLayoutConstraint(
            item: view,
            attribute: .width,
            relatedBy: relation,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: constant
        )
        width.identifier = identifier
        NSLayoutConstraint.activate([ width ])
    }

    static func fixHeight(view: UIView, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let identifier = "FixHeightConstraint"
        view.removeConstraints(view.constraints.filter { $0.identifier == identifier })

        let height = NSLayoutConstraint(
            item: view,
            attribute: .height,
            relatedBy: relation,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: constant
        )

        height.identifier = identifier
        NSLayoutConstraint.activate([ height ])
    }
}

extension UILayoutPriority {
    static func + (left: UILayoutPriority, right: Float) -> UILayoutPriority {
        return UILayoutPriority(left.rawValue + right)
    }

    static func - (left: UILayoutPriority, right: Float) -> UILayoutPriority {
        return UILayoutPriority(left.rawValue - right)
    }
}
public struct ConstraintAttribute<T: AnyObject> {
    let anchor: NSLayoutAnchor<T>
    let const: CGFloat
}
public struct LayoutGuideAttribute {
    let guide: UILayoutSupport
    let const: CGFloat
}
@discardableResult
public func ~= (lhs: NSLayoutYAxisAnchor, rhs: UILayoutSupport) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs.bottomAnchor)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(lessThanOrEqualTo: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func >= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(greaterThanOrEqualTo: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= <T>(lhs: NSLayoutAnchor<T>, rhs: ConstraintAttribute<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs.anchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= (lhs: NSLayoutYAxisAnchor, rhs: LayoutGuideAttribute) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs.guide.bottomAnchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalToConstant: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= <T>(lhs: NSLayoutAnchor<T>, rhs: ConstraintAttribute<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    let constraint = lhs.constraint(lessThanOrEqualToConstant: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func >= <T>(lhs: NSLayoutAnchor<T>, rhs: ConstraintAttribute<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func >= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    let constraint = lhs.constraint(greaterThanOrEqualToConstant: rhs)
    constraint.isActive = true
    return constraint
}
public func + <T>(lhs: NSLayoutAnchor<T>, rhs: CGFloat) -> ConstraintAttribute<T> {
    return ConstraintAttribute(anchor: lhs, const: rhs)
}

public func + (lhs: UILayoutSupport, rhs: CGFloat) -> LayoutGuideAttribute {
    return LayoutGuideAttribute(guide: lhs, const: rhs)
}

public func - <T>(lhs: NSLayoutAnchor<T>, rhs: CGFloat) -> ConstraintAttribute<T> {
    return ConstraintAttribute(anchor: lhs, const: -rhs)
}

public func - (lhs: UILayoutSupport, rhs: CGFloat) -> LayoutGuideAttribute {
    return LayoutGuideAttribute(guide: lhs, const: -rhs)
}
