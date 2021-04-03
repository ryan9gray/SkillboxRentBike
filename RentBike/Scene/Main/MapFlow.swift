//
//  MapFlow.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.02.2021.
//

import UIKit
import MapKit

class MapFlow {
    let rootVC: RootViewController = RootViewController.init(nibName: nil, bundle: nil)
    let service = NetworkService.shared

    var inProgress: Bool {
        if let ride = bike {
            return ride.status != .free
        } else {
            return false
        }
    }
    var bike: Bike?
    var annotation: BikeAnnotataion?

    func start() {
        rootVC.setViewControllers([ createInitialViewController() ], animated: false)
    }
    
    lazy var initialViewController: DrawerController = {
        let drawler = DrawerController(rootViewController: rootVC, menuController: MenuViewController.instantiate(fromStoryboard: .main))
        return drawler
    }()

    /// Утечка памяти
    private func createInitialViewController() -> UIViewController {
        let controller = MapViewController.instantiate(fromStoryboard: .main)
        controller.input = .init(
            inProgress: { [weak self] in self?.inProgress ?? false  },
            load: loadInitialData
        )
        controller.output = .init(
            start: startRide,
            moved: moved,
            lock: lock,
            light: light
        )
        return controller
    }

    func startRide(annotation: BikeAnnotataion) {

    }

    func light(_ completion: @escaping (Bool) -> Void) {

    }

    func lock(_ completion: @escaping (Bool) -> Void) {

    }

    func moved(coordinate: CLLocation) {

    }

    func loadInitialData(_ completion: @escaping ([BikeAnnotataion]) -> Void) {
        guard
            let fileName = Bundle.main.url(forResource: "Bikes", withExtension: "geojson"),
            let artworkData = try? Data(contentsOf: fileName)
        else { return completion([]) }

        do {
            let features = try MKGeoJSONDecoder()
                .decode(artworkData)
                .compactMap { $0 as? MKGeoJSONFeature }
            let validWorks = features.compactMap(BikeAnnotataion.init)
            completion(validWorks)
        } catch {
            print("Unexpected error: \(error).")
            return completion([])
        }
    }
}
