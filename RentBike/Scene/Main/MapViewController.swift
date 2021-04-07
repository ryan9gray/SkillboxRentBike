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
    @IBOutlet private var lightButton: RoundEdgeButton!
    @IBOutlet private var lockButton: RoundEdgeButton!
    @IBOutlet private var finishButton: RoundEdgeButton!
    @IBOutlet private var locationButton: RoundEdgeButton!
    @IBOutlet var actButtons: [RoundEdgeButton]!

    private var bikes: [BikeAnnotataion] = []
    private var currentLocation: CLLocation? {
        didSet {
            guard let location = currentLocation else { return }
            if oldValue == nil {
                output.sendMyLocation(location)
            }
			locationDidUpdated(location)
        }
    }

    func locationDidUpdated(_ location: CLLocation) {
        updateMapOverlayViews(coordinate: location.coordinate)
        if input.bike()?.status == .some(.inProgress) {
            output.moved(location)
        }

        guard let bike = input.bike() else { return }
        switch bike.status {
            case .inProgress:
                output.moved(location)
            case .booked:
                if location.distance(from: bike.coordinate) < BikeProfile.maxDistanse {
                    output.start(selectedBike!)
                }
            default:
                break
        }
    }

    private var selectedBike: BikeAnnotataion? {
        didSet {
            if oldValue == nil {

            }
            setButtons()
        }
    }

    struct Output {
        var start: (BikeAnnotataion) -> Void
        var moved: (CLLocation) -> Void
        var lock: (_ completion: @escaping (Bool) -> Void) -> Void
        var light: (_ completion: @escaping (Bool) -> Void) -> Void
        var sendMyLocation: (CLLocation) -> (Void)
    }

    struct Input {
        var bike: () -> Bike?
        var load: (_ completion: @escaping ([BikeAnnotataion]) -> Void) -> Void
    }
    
    var input: Input!
    var output: Output!

    @IBAction func locationTap(_ sender: Any) {
        guard let location = currentLocation else { return }
        mapView.centerToLocation(location)
        output.sendMyLocation(location)
    }

    @IBAction func finishTap(_ sender: Any) {
        toRent()
    }

    @IBAction func lightTap(_ sender: Any) {
        lightButton.isSelected.toggle()
        output.light { bool in
            self.updateButtons()
        }
    }

    @IBAction func lockTap(_ sender: Any) {
        lockButton.isSelected.toggle()
        output.lock { bool in
            self.updateButtons()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        LocationTracker.shared.delegate = self
        actButtons.forEach { $0.isHidden = true }
        LocationTracker.shared.authorizeLocationTracking()
    }

    func setBike(_ bike: Bike) {
        guard bikes.isEmpty else { return }

        let anotaion = BikeAnnotataion(
            title: "BMW",
            locationName: nil,
            discipline: nil,
            coordinate: .init(latitude: bike.latitude, longitude: bike.longitude)
        )
        self.bikes.append(anotaion)
        self.mapView.addAnnotations(self.bikes)
        updateButtons()
    }

    func setButtons() {
        finishButton.isHidden = selectedBike == nil
    }

    func toRent() {
        guard let anotation = selectedBike else { return }
        output.start(anotation)
    }

    func updateButtons() {
        guard let bike = input.bike() else { return }
        lightButton.isSelected = bike.lightOn
        lockButton.isSelected = bike.isUnlock
        finishButton.isSelected = bike.inProgress
        lightButton.isHidden = !bike.inProgress
        lockButton.isHidden = !bike.inProgress
    }

    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        mapView.register(
            BikeView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
    }

    func updateMapOverlayViews(coordinate: CLLocationCoordinate2D) {
        mapView.removeOverlays(mapView.overlays)
        if let bike = selectedBike,
           input.bike()?.status == .some(.inProgress),
           let location = currentLocation
        {
            mapView.removeAnnotation(bike)

            bike.coordinate = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            mapView.addAnnotation(bike)
        }
        let circleOverlay = MKCircle(
            center: coordinate,
            radius: BikeProfile.maxDistanse
        )
        mapView.addOverlay(circleOverlay)
    }

    func showInvalidDistanceAlert() {
        let alert = UIAlertController(
            title: "Booked",
            message: "Please enter a valid distance in kilometers",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 3000) {
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
        guard let bike = view.annotation as? BikeAnnotataion else { return }
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        bike.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let bike = view.annotation as? BikeAnnotataion else { return }
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    func locationTrackerDidChangeAuthorizationStatus(_ locationTracker: LocationTracker) {
    }
}
