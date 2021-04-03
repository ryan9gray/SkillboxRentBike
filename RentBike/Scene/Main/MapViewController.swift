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
            if oldValue == nil {
                setBikes()
            }
            guard let location = currentLocation else { return }
            updateMapOverlayViews(coordinate: location.coordinate)
            if input.inProgress() {
                output.moved(location)
            }
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
    }
    struct Input {
        var inProgress: () -> Bool
        var load: (_ completion: @escaping ([BikeAnnotataion]) -> Void) -> Void
    }
    var input: Input!
    var output: Output!

    @IBAction func locationTap(_ sender: Any) {
        guard let location = currentLocation else { return }
        mapView.centerToLocation(location)
    }

    @IBAction func finishTap(_ sender: Any) {
        toRent()
    }

    @IBAction func lightTap(_ sender: Any) {
        lightButton.isSelected.toggle()
        output.light { bool in
            self.lightButton.isSelected = bool
        }
    }

    @IBAction func lockTap(_ sender: Any) {
        lockButton.isSelected.toggle()
        output.lock { bool in
            self.lockButton.isSelected = bool
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        LocationTracker.shared.delegate = self
        actButtons.forEach { $0.isHidden = true }
        LocationTracker.shared.authorizeLocationTracking()
    }

    func setBikes() {
        input.load { [weak self] bikes in
            guard let self = self else { return }
            self.bikes.append(contentsOf: bikes)
            self.mapView.addAnnotations(self.bikes)
        }
    }

    func setButtons() {
        guard let bike = selectedBike else { return }

        actButtons.forEach { $0.isHidden = false }
    }

    func toRent() {
        guard let bike = selectedBike else { return }
        guard let dist = currentLocation?.distance(
            from: CLLocation(latitude: bike.coordinate.latitude, longitude: bike.coordinate.longitude)
        ) else { return }
        if dist > BikeProfile.maxDistanse {
			showInvalidDistanceAlert()
        } else {
            output.start(bike)
            finishButton.isSelected = true
        }
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
           input.inProgress(),
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

    private func showInvalidDistanceAlert() {
        let alert = UIAlertController(
            title: nil,
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
