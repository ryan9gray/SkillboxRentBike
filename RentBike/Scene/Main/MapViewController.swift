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
    @IBOutlet private var buttonsStackView: UIStackView!
    @IBOutlet private var mapView: MKMapView!
    fileprivate var menuButton: UIBarButtonItem!

    private var bikes: [Bike] = []
    private var currentLocation: CLLocation?
    private var selectedBike: Bike? {
        didSet {
            setButtons()
        }
    }

    struct Input {
        let menu: () -> Void
    }
    var input: Input!

    @IBAction func locationTap(_ sender: Any) {
        guard let location = currentLocation else { return }
        mapView.centerToLocation(location)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //menuButton = UIBarButtonItem(image: UIImage.init(named: "hamburger-menu-icon"), style: .plain, target: self, action: #selector(handleMenuButton))
        navigationItem.leftBarButtonItem = menuButton
        setupMap()
        loadInitialData()
        mapView.addAnnotations(bikes)
        LocationTracker.shared.delegate = self
    }

    @objc func handleMenuButton() {
        input.menu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setButtons() {
        buttonsStackView.subviews.forEach { $0.removeFromSuperview() }
        guard let bike = selectedBike else {
            return
        }
        let lock = RoundEdgeButton().prepareForAutoLayout()
        lock.setTitle("З", for: .normal)
        buttonsStackView.addArrangedSubview(lock)
        let f = RoundEdgeButton().prepareForAutoLayout()
        f.backgroundColor = .white
        f.setTitle("Ф", for: .normal)

        
        buttonsStackView.addArrangedSubview(f)
        let finish = RoundEdgeButton().prepareForAutoLayout()
        finish.setTitle("Finish", for: .normal)

        buttonsStackView.addArrangedSubview(finish)
    }

    // MARK: setup
    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        mapView.register(
            BikeView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        //mapView.setUserTrackingMode(.followWithHeading, animated: true)
        if let homeLocation = BikeProfile.homeLocation,
           let safeDistanceFromHome = BikeProfile.safeDistanceFromHome {
            let circleOverlay = MKCircle(center: homeLocation.coordinate,
                                         radius: safeDistanceFromHome)

            mapView.addOverlay(circleOverlay)
        }
    }

    /// Force set location
    func followUserLocation() {
        if let location = LocationTracker.shared.locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 4000, longitudinalMeters: 4000)
            mapView.setRegion(region, animated: true)
        }
    }

    private func loadInitialData() {
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
            bikes.append(contentsOf: validWorks)
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
        guard let bike = view.annotation as? Bike else { return }
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        bike.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let bike = view.annotation as? Bike else { return }
        selectedBike = bike
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let overlay = overlay as? MKCircle{
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.green
            circleRenderer.alpha = 0.2
            return circleRenderer
        }

        return MKOverlayRenderer(overlay: overlay)
    }
}
extension MapViewController: LocationTrackerDelegate {
    func locationTrackerDidChangeAuthorizationStatus(_ locationTracker: LocationTracker) {

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        mapView.centerToLocation(location)
    }

}
