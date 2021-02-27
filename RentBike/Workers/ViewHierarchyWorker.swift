
import UIKit

struct ViewHierarchyWorker {
    
    static var mainWindow: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
		//return ApplicationFlow.shared.window
    }
    
    static func setRootViewController(_ rootViewController: UIViewController, of window: UIWindow! = mainWindow) {
        guard let window = window else { print("window is nil"); return }

        UIView.transition(with: window, duration: 0.5, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
			let oldState = UIView.areAnimationsEnabled
			UIView.setAnimationsEnabled(false)
			window.rootViewController = rootViewController
			UIView.setAnimationsEnabled(oldState)
        }, completion: nil)
    }
    
    static func resetAppForAuthentication() {
        DispatchQueue.main.async {
            func isAlreadyReseted() -> Bool {
                mainWindow?.rootViewController?.children.first is AuthViewController
            }
            guard !isAlreadyReseted() else { return }

            let flow = AuthFlow()
            flow.start()
            ViewHierarchyWorker.setRootViewController(flow.initialViewController)
        }
    }
    
    static func resetAppForMain() {
        DispatchQueue.main.async {
            func isAlreadyReseted() -> Bool {
                mainWindow?.rootViewController?.tabBarController == nil
            }
            guard isAlreadyReseted() else { return }
            
			let controller = ApplicationFlow.shared.mainTabBarController()
            ViewHierarchyWorker.setRootViewController(controller)
        }
    }
}

enum StoryboardWorker: String {
    case autorization =         "Auth"
    case main =                 "Main"
    case feed =                 "Feed"
    case profile =              "Profile"
    case basket =               "Basket"
    case discount =              "Discount"



    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: Bundle.main)
    }

    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }

    func instantiateViewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        guard let vc = instance.instantiateViewController(withIdentifier: String(describing: viewControllerClass)) as? T else {
            fatalError("ViewController with identifier \(String(describing: viewControllerClass)), not found in \(rawValue)")
        }
        return vc
    }
}
