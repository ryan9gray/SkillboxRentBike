

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(withCell cellType: T.Type, for indexPath: IndexPath) -> T {
        let identifier = cellType.cellIdentifier
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("\(identifier) isn't registered")
        }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withCell cellType: T.Type) -> T {
        let identifier = cellType.cellIdentifier        
        guard let cell = dequeueReusableCell(withIdentifier: identifier) as? T else {
            fatalError("\(identifier) isn't registered")
        }
        return cell
    }

	func dequeueReusableHeaderCell<T: UIView>(withCell cellType: T.Type) -> T {
		let identifier = String(describing: cellType)
		guard let cell = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
			fatalError("\(identifier) isn't registered")
		}
		return cell
	}

	func register(cells: [UITableViewCell.Type], fromBundle bundle: Bundle = Bundle.main) {
		for cell in cells {
			let identifier = String(describing: cell.cellIdentifier)
			if let _ = bundle.url(forResource: identifier, withExtension: "nib") {
				let nib = UINib(nibName: identifier, bundle: bundle)
				register(nib, forCellReuseIdentifier: identifier)
			} else {
				register(cell, forCellReuseIdentifier: identifier)
			}
		}
	}
    func register<T: UITableViewHeaderFooterView>(headerFooterView: T.Type) {
        let sectionIdentifier = String(describing: headerFooterView.self)
        let nib = UINib(nibName: sectionIdentifier, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: sectionIdentifier)
    }
    
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        let reuseIdentifier = String(describing: cellClass)
        let nib = UINib(nibName: reuseIdentifier, bundle: nil)
        register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func reloadVisibleRows(with animation: UITableView.RowAnimation) {
        if let indexPaths = indexPathsForVisibleRows {
            reloadRows(at: indexPaths, with: animation)
        }
    }
    
    func sizeToFitTableHeaderView() {
        guard let header = tableHeaderView else { return }

        let headerWidth = bounds.width

        let headerHeight = header.minSize(thatFits: CGSize(width: headerWidth, height: UIView.noIntrinsicMetric)).height
        guard headerHeight != header.frame.height else { return }

        header.frame.size = CGSize(width: headerWidth, height: headerHeight)
        tableHeaderView = header

        layoutIfNeeded()
    }
}
