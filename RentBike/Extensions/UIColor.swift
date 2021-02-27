
import UIKit

extension UIColor {

    enum Cell {
        static let highlighted                  = #colorLiteral(red: 0.5764705882, green: 0.5450980392, blue: 0.5450980392, alpha: 1).withAlphaComponent(0.05)  // 938B8B
        static let separator                    = #colorLiteral(red: 0.5764705882, green: 0.5450980392, blue: 0.5450980392, alpha: 1).withAlphaComponent(0.1)   // 938B8B
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        var hexInt: UInt32 = 0
        Scanner(string: hex).scanHexInt32(&hexInt)
        self.init(with: hexInt, alpha: alpha)
    }
    
    public convenience init(with hex: UInt32, alpha: CGFloat = 1.0) {
        let colorComponents = (
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 08) & 0xff) / 255,
            blue: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(
            red: colorComponents.red,
            green: colorComponents.green,
            blue: colorComponents.blue,
            alpha: alpha
        )
    }
}
