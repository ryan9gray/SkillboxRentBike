//
//  MapFlow.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.02.2021.
//

import UIKit

class MapFlow {

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
        let controller = MapViewController.instantiate(fromStoryboard: .main)


        return controller
    }
}
