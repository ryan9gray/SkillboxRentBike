//
//  RootViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 22.03.2021.
//

import UIKit

protocol RootViewControllerDelegate: class {
    func rootViewControllerDidTapMenuButton(_ rootViewController: RootViewController)
}

class RootViewController: UINavigationController, UINavigationControllerDelegate {
    fileprivate var menuButton: UIBarButtonItem!
    weak var drawerDelegate: RootViewControllerDelegate?

//    public init(mainViewController: UIViewController) {
//        super.init(rootViewController: mainViewController)
//
//    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        menuButton = UIBarButtonItem(image: UIImage(named: "hamburger-menu-icon"), style: .plain, target: self, action: #selector(handleMenuButton))
        self.delegate = self
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        prepareNavigationBar()
    }
}

extension RootViewController {
    fileprivate func prepareNavigationBar() {
        topViewController?.navigationItem.title = topViewController?.title
        if self.viewControllers.count <= 1 {
            topViewController?.navigationItem.leftBarButtonItem = menuButton
        }
    }
}

extension RootViewController {
    @objc
    fileprivate func handleMenuButton() {
        drawerDelegate?.rootViewControllerDidTapMenuButton(self)
    }
}

