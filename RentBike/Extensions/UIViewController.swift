
import Foundation
import UIKit

extension UIViewController {
    static func instantiate(fromStoryboard storyboard: StoryboardWorker) -> Self {
        return storyboard.instantiateViewController(viewControllerClass: self)
    }

	func fromNib<T: UIViewController>(viewControllerClass: T.Type) -> T {
		let vc = viewControllerClass.init(nibName: String(describing: viewControllerClass), bundle: Bundle(for: viewControllerClass))
		return vc
	}
}
extension UIViewController {
    func hideKeyboardWhenTappedAround(cancelsTouchesInView: Bool = false) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = cancelsTouchesInView
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    var className: String {
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!;
    }
}

extension UIViewController {
    func child<T>() -> T? {
        if let result = children.first(where: { return $0 is T }) as? T {
            return result
        }
        return nil
    }
}

extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

