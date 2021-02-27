//
//  ApplicationFlow.swift
//  Mems
//
//  Created by Evgeny Ivanov on 29.11.2019.
//  Copyright © 2019 Eugene Ivanov. All rights reserved.
//
import UIKit

class ApplicationFlow {
    static let shared = ApplicationFlow()

	private init() { }

    let profileFlow = ProfileFlow()
    let feedFlow = FeedFlow()
    let basketFlow = BasketFlow()
    let discountFlow = DiscountFlow()

    func start() {
        profileFlow.start()
        feedFlow.start()
        basketFlow.start()
        discountFlow.start()

		//startMain()
		if Profile.isAuthorized {
			startMain()
		} else {
			ViewHierarchyWorker.resetAppForAuthentication()
		}
	}

	func startMain() {
		ViewHierarchyWorker.resetAppForMain()
	}

    var tabBarController: MainTabBarController?

    func mainTabBarController() -> MainTabBarController {
        let tabBarController = MainTabBarController.instantiate(fromStoryboard: .main)

        tabBarController.setViewControllers([
            feedFlow.initialViewController,
            profileFlow.initialViewController,
            discountFlow.initialViewController,
            basketFlow.initialViewController,
        ], animated: false)

		if #available(iOS 13.0, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.titleTextAttributes = [.foregroundColor: Style.Color.black]
			tabBarController.viewControllers?.forEach({ controller in
				controller.navigationController?.navigationBar.standardAppearance = appearance
			})
		}
		self.tabBarController = tabBarController
        return tabBarController
    }

    func showAlert(_ text: String) {
        let alertController = UIAlertController(
            title: text,
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}
