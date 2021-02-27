
import UIKit

enum Style {
    enum Color {
        static let carminePink      = UIColor(hex: "F43B3B")
        static let black    		= UIColor.black
		static let gray    			= UIColor(hex: "778D9A")
        static let lightGray        = UIColor(hex: "F8F8F8")
		static let loblolly    		= UIColor(hex: "BFCAD1")
		static let blue    			= UIColor(hex: "3F8AE0")
		static let mercury    		= UIColor(hex: "E5E5E5")
    }

    enum Font {
        static func main(size: CGFloat) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: .regular)
        }
		static func semibold(size: CGFloat) -> UIFont {
			UIFont.systemFont(ofSize: size, weight: .semibold)
		}
		static func bold(size: CGFloat) -> UIFont {
			UIFont.systemFont(ofSize: size, weight: .bold)
		}
        static let title = main(size: 20)
    }

    enum TextAttributes {
        static var textColor: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return Style.Color.black
            }
        }
        static var backColor: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor.systemBackground
            } else {
                return UIColor.white
            }
        }

        static let subheadSemibold: [NSAttributedString.Key: Any] = [
            .font: Style.Font.semibold(size: 14),
            .foregroundColor: Style.Color.black
        ]
		static let regular: [NSAttributedString.Key: Any] = [
			.font: Style.Font.main(size: 15),
            .foregroundColor: TextAttributes.textColor
		]
        static let tabSelected: [NSAttributedString.Key: Any] = [
            .font: Style.Font.main(size: 15),
            .foregroundColor: Style.Color.carminePink
        ]
		static let grayRegular: [NSAttributedString.Key: Any] = [
			.font: Style.Font.main(size: 13),
			.foregroundColor: Style.Color.gray
		]
		static let titleSemibold: [NSAttributedString.Key: Any] = [
			.font: Style.Font.semibold(size: 17),
			.foregroundColor: Style.Color.black
		]
        static let agreementLink: [NSAttributedString.Key: Any] = [
            .font: Style.Font.main(size: 12),
            .foregroundColor: Style.Color.carminePink
        ]
        static let agreement: [NSAttributedString.Key: Any] = [
            .font: Style.Font.main(size: 12),
            .foregroundColor: Style.Color.gray
        ]
        static func fontPicker(font: UIFont) -> [NSAttributedString.Key: Any] {
            [
                .font: font.withSize(18),
                .foregroundColor: UIColor.white
            ]
        }
    }

}

protocol Applicable {
    associatedtype Applicant

    func apply(_ object: Applicant)
}

precedencegroup StylePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator <~: StylePrecedence

@discardableResult
func <~<T: Applicable>(object: T.Applicant, applicable: T) -> T.Applicant {
    applicable.apply(object)
    return object
}

func <~ (string: String, attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
    return NSAttributedString(string: string, attributes: attributes)
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
	let result = NSMutableAttributedString(attributedString: left)
	result.append(right)
	return result
}

@discardableResult
func <~ (string: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
    string.addAttributes(attributes, range: NSRange(location: 0, length: string.length))
    return string
}

func <~ (attributesTo: [NSAttributedString.Key: Any], attributesFrom: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
    var resultAttributes = attributesTo
    attributesFrom.forEach { item in
        resultAttributes[item.key] = item.value
    }
    return resultAttributes
}

precedencegroup ForwardApplication {
  associativity: left
}
infix operator |>: ForwardApplication
public func |> <A, B>(x: A, f: (A) -> B) -> B {
  return f(x)
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: SingleTypeComposition
}
infix operator >>>: ForwardComposition
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { g(f($0)) }
}

precedencegroup SingleTypeComposition {
  associativity: right
  higherThan: ForwardApplication
}
infix operator <>: SingleTypeComposition
public func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
  return f >>> g
}
public func <> <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
  return { a in
    f(&a)
    g(&a)
  }
}
extension NSAttributedString {
    var mutable: NSMutableAttributedString { NSMutableAttributedString(attributedString: self) }
}

extension NSMutableAttributedString {
    /// Replaces string with specified attributed string.
    func replace(_ string: String, with attributedString: NSAttributedString) {
        let range = (self.string as NSString).range(of: string)

        guard range.location != NSNotFound else {
            let exclamation = "\u{203C}\u{FE0F}"
            let alarm = "\(exclamation) \(string) is absent \(exclamation)"
            let attributedAlarm = NSAttributedString(string: alarm, attributes: [ .foregroundColor: Style.Color.carminePink ])
            insert(attributedAlarm, at: 0)
            return
        }

        replaceCharacters(in: range, with: attributedString)
    }
}
