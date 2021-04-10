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
    let rideService = RideService()
    let controller = MapViewController.instantiate(fromStoryboard: .main)
	let notificationService = NotificationService()
    var bike: Bike?
    var startAnotation: BikeAnnotataion?

    func start() {
        rootVC.setViewControllers([ createInitialViewController() ], animated: false)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendCoord),
            name: NSNotification.Name.SendCoord,
            object: nil
        )
    }
    
    lazy var initialViewController: DrawerController = {
        let drawler = DrawerController(rootViewController: rootVC, menuController: MenuViewController.instantiate(fromStoryboard: .main))
        return drawler
    }()

    /// Утечка памяти
    private func createInitialViewController() -> UIViewController {
        controller.input = .init(
            bike: { self.bike },
            load: loadInitialData
        )
        // утечка памяти
        controller.output = .init(
            start: startRide,
            moved: moved,
            lock: lock,
            light: light,
            sendMyLocation: changeProfile
        )
        return controller
    }

    func distanse(coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let dist = LocationTracker.shared.locationManager.location?.distance(
            from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        ) else { return nil }
        return dist
    }

    func startRide(annotation: BikeAnnotataion) {
        guard let bike = bike else { return }
        guard let dist = distanse(coordinate: annotation.coordinate) else {
            return
        }
        if dist > BikeProfile.maxDistanse {
            if bike.status == .booked {
                bike.status = .free
                rideService.book(id: bike.id, start: false)
            } else {
            	rideService.book(id: bike.id, start: true)
            	bike.status = .booked
            	controller.showInvalidDistanceAlert()
            }
        } else {
            switch bike.status {
                case .booked, .free:
                    notificationService.startTimer()
                    controller.startTimer()
                    bike.status = .inProgress
                    startAnotation = annotation
                    rideService.rideStart(id: bike.id)
                case .inProgress:
                    if !bike.lightOn {
                        notificationService.stopTimer()
                    }
                    let anot = startAnotation?.coordinate ?? annotation.coordinate
                    bike.status = .free
                    rideService.rideFinish(.init(bikeId: bike.id, distance: Int(distanse(coordinate: anot)!)))
                    Profile.current?.lastBike = bike
                    controller.stopTimer()
            }
        }
        controller.updateButtons()
    }

    func light(_ completion: @escaping (Bool) -> Void) {
        bike?.lightOn.toggle()
        updateBike(completion: { bike in
            guard let bike = bike else { return }
            self.bike = bike
            completion(bike.lightOn)
        })
    }

    func lock(_ completion: @escaping (Bool) -> Void) {
        bike?.isUnlock.toggle()
        updateBike(completion: { bike in
            guard let bike = bike else { return }
            completion(bike.isUnlock)
        })
    }

    func updateBike(completion: @escaping (Bike?) -> Void) {
        guard let bike = bike else { return }
        rideService.bikeChange(.init(lightOn: bike.lightOn, isUnlock: bike.isUnlock), id: bike.id, completion: completion)
        controller.updateButtons()
    }

    func moved(coordinate: CLLocation) {
        bike?.longitude = coordinate.coordinate.longitude
        bike?.latitude = coordinate.coordinate.latitude

    }
    @objc func sendCoord() {
        guard let bike = bike else { return }
        service.move(coordinate: .init(
            latitude: bike.latitude,
            longitude: bike.longitude
        ))
    }

    func changeProfile(coordinate: CLLocation) {
        Profile.current?.latitude = coordinate.coordinate.latitude
        Profile.current?.longitude = coordinate.coordinate.longitude
        service.update { _ in
            self.rideService.getNearBike { bike in
                guard let bike = bike else { return }  
                Profile.current?.lastBike = bike
                Profile.current?.save()
                self.bike = bike
                self.controller.setBike(bike)
            }
        }
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
