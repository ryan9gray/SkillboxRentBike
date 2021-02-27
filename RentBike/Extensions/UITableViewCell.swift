

import UIKit

extension UITableViewCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
}
extension UICollectionReusableView {
	static var cellIdentifier: String {
		return String(describing: self)
	}
}
