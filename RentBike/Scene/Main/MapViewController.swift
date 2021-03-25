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

    private var bikes: [Bike] = []
    private var currentLocation: CLLocation? {
        didSet {
            guard let location = currentLocation else { return }
            updateMapOverlayViews(coordinate: location.coordinate)
            if input.inProgress() {
                output.moved(location)
            }
        }
    }
    private var selectedBike: Bike? {
        didSet {
            setButtons()
        }
    }

    struct Output {
        var start: () -> Void
        var moved: (CLLocation) -> Void
    }
    struct Input {
        var inProgress: () -> Bool
    }

    var input: Input!
    var output: Output!

    @IBAction func locationTap(_ sender: Any) {
        guard let location = currentLocation else { return }
        mapView.centerToLocation(location)
    }
    @IBAction func finishTap(_ sender: Any) {

        finishButton.isSelected.toggle()
    }
    @IBAction func lightTap(_ sender: Any) {
        lightButton.isSelected.toggle()
    }
    @IBAction func lockTap(_ sender: Any) {
        lockButton.isSelected.toggle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        loadInitialData()
        mapView.addAnnotations(bikes)
        LocationTracker.shared.delegate = self
        actButtons.forEach { $0.isHidden = true }
        LocationTracker.shared.authorizeLocationTracking()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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

        }
    }

    fileprivate func showInvalidDistanceAlert() {
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

    // MARK: setup
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
        let circleOverlay = MKCircle(
            center: coordinate,
            radius: BikeProfile.maxDistanse
        )
        mapView.addOverlay(circleOverlay)
    }

    private func loadInitialData() {
        guard
            let fileName = Bundle.main.url(forResource: "Bikes", withExtension: "geojson"),
            let artworkData = try? Data(contentsOf: fileName)
        else { return }
        
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
    }
}
