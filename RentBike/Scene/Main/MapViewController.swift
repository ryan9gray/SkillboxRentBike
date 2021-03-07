//
//  MapViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.02.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet var buttonsStackView: UIStackView!
    @IBOutlet var mapView: MKMapView!

    private var artworks: [Bike] = []
    var isLocationServiceEnabled: Bool { CLLocationManager.locationServicesEnabled() }
    private let manager: CLLocationManager = CLLocationManager()

    @IBAction func locationTap(_ sender: Any) {
        requestCurrentLocation()
    }
    @IBAction func menuTap(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()

        loadInitialData()
    }

    private func setupMap() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.register(
            Bike.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
    }
    func requestCurrentLocation() {
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }

    private func loadInitialData() {
        // 1
        guard
            let fileName = Bundle.main.url(forResource: "Bikes", withExtension: "geojson"),
            let artworkData = try? Data(contentsOf: fileName)
        else {
            return
        }

        do {
            let features = try MKGeoJSONDecoder()
                .decode(artworkData)
                .compactMap { $0 as? MKGeoJSONFeature }
            let validWorks = features.compactMap(Bike.init)
            artworks.append(contentsOf: validWorks)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let artwork = view.annotation as? Bike else {
            return
        }

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        artwork.mapItem?.openInMaps(launchOptions: launchOptions)
    }
}
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }


        if let location = manager.location {
            locationManager(manager, didUpdateLocations: [ location ])
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        mapView.centerToLocation(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
