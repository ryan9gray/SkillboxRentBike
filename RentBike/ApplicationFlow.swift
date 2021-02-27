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
    let mapFlow = MapFlow()

    func start() {
        mapFlow.start()
        profileFlow.start()
        
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

    func mainController() -> UIViewController {
        let vc = mapFlow.initialViewController
        return vc
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
