import UIKit
import Foundation

extension String {
    var localized: Self {
        NSLocalizedString(self, comment: "")
    }

    var boolValue: Bool {
        self == "true"
    }

    var doubleValue: Double? {
        Double(self)
    }

    var appointmentDateString: Date? {
        let dateFormat = "dd.MM.yyyy"
        return date(withFormat: dateFormat)
    }

    private func date(withFormat format: String) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.timeZone = TimeZone.current
        inputFormatter.dateFormat = format
        return inputFormatter.date(from: self)
    }
    

    func textSize(width: CGFloat, font: UIFont, numberOfLines: Int = Int.max) -> CGSize {
        let myString = self as NSString
        let maxHeight: CGFloat = font.lineHeight * CGFloat(numberOfLines)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        let rectNeeded = myString.boundingRect(with: CGSize(width: width, height: maxHeight),
                                               options: .usesLineFragmentOrigin,
                                               attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraph],
                                               context: nil)
        
        return rectNeeded.size
    }

    func substring(with range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }

	var isValidEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: self)
	}
    
    func contains(from characterSet: CharacterSet) -> Bool {
        rangeOfCharacter(from: characterSet) != nil
    }

	func fromBase64() -> String? {
		guard let data = Data(base64Encoded: self) else {
			return nil
		}

		return String(data: data, encoding: .utf8)
	}

	func toBase64() -> String {
		return Data(self.utf8).base64EncodedString()
	}
}
