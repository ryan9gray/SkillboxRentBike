//
//  MapFlow.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.02.2021.
//

import UIKit

class MapFlow {
    let rootVC: RootViewController = RootViewController.init(nibName: nil, bundle: nil)
    let service = NetworkService.shared

    var inProgress: Bool = false

    init() {
    }

    func start() {
        rootVC.setViewControllers([ createInitialViewController() ], animated: false)
    }
    
    lazy var initialViewController: DrawerController = {
        let drawler = DrawerController(rootViewController: rootVC, menuController: MenuViewController.instantiate(fromStoryboard: .main))
        return drawler
    }()

    private func createInitialViewController() -> UIViewController {
        let controller = MapViewController.instantiate(fromStoryboard: .main)
        controller.input = .init(
            inProgress: { [weak self] in self?.inProgress ?? false  }
        )
        controller.output = .init(
            start: { [weak self] in
                self?.startRide()
            },
            moved: { coordinate in

            }
        )
        return controller
    }

    func startRide() {

    }
}

struct RideStat {
    
}
