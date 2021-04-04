//
//  ProfileFlow.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.02.2021.
//

import UIKit
import Firebase
import GoogleSignIn

class ProfileFlow {

    let initialViewController: UINavigationController
    let service = NetworkService.shared

    init() {
        let navigationController = UINavigationController()
        initialViewController = navigationController
    }

    func start() {
        initialViewController.setViewControllers([ createInitialViewController() ], animated: false)
    }

    private func createInitialViewController() -> UIViewController {
        let controller = ProfileViewController.instantiate(fromStoryboard: .profile)
        controller.output = .init(
            getAvatar: getProfile,
            upload: uploadImage
            //            infoOpen: { [weak controller] in
            //                self.openInfo(from: controller)
            //            }
        )
        
        return controller
    }

    func uploadImage(_ image: UIImage?) {

    }

    func getProfile(complition: @escaping (Profile?) -> Void) {
        service.getProfile(complition: complition)
    }

    func openInfo(from: UIViewController?) {
//        let controller = InfoViewController.instantiate(fromStoryboard: .profile)
//        controller.output = .init(getAvatar: getProfile, upload: uploadImage)
//        from?.navigationController?.pushViewController(controller, animated: true)
    }
}
