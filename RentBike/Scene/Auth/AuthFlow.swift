//
//  AuthFlow.swift
//  SkillBoxTester
//
//  Created by Evgeny Ivanov on 13.08.2020.
//  Copyright © 2020 Evgeny Ivanov. All rights reserved.
//

import UIKit

class AuthFlow {
    let initialViewController: UINavigationController

    let service = AuthService()

    init() {
        let navigationController = UINavigationController()
        initialViewController = navigationController
    }

    func start() {
        initialViewController.setViewControllers([ createInitialViewController() ], animated: false)
        initialViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "icQuestions"),
            selectedImage: UIImage(named: "icQuestions")
        )
    }

    func signGoogle(_ token: String) {
        service.logIn(
            end: .login,
            params: AuthService.Body(
                type: AuthService.AuthType.google.rawValue,
                creds: AuthService.Cred(gtoken: token, login: "", password: "")
            )
        ){ profile in
            if profile != nil {
                ApplicationFlow.shared.startMain()
            }
        }
    }

    func registrate(login: String, pass: String) {
        service.logIn(
            end: .signup,
            params: AuthService.Body(
                type: AuthService.AuthType.email.rawValue,
                creds: AuthService.Cred(gtoken: "", login: login, password: pass)
            )
        ){ [weak self] profile in
            self?.login(login: login, pass: pass)
//            if profile != nil {
//                ApplicationFlow.shared.startMain()
//            }
        }
    }
    func login(login: String, pass: String) {
        service.logIn(
            end: .login,
            params: AuthService.Body(
                type: AuthService.AuthType.email.rawValue,
                creds: AuthService.Cred(gtoken: "", login: login, password: pass)
            )
        ){ profile in
            if profile != nil {
                ApplicationFlow.shared.startMain()
            }
        }
    }


    func createInitialViewController() -> UIViewController {
        let controller = AuthViewController.instantiate(fromStoryboard: .autorization)
        controller.output = .init(
            google: signGoogle,
            reg: registrate,
            log: login
        )
        return controller
    }
    
}

