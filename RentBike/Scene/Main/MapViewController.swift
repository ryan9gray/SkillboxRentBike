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
    private var bikes: [Bike] = []
    private var currentLocation: CLLocation? {
        didSet {
            guard let location = currentLocation else { return }
            updateMapOverlayViews(coordinate: location.coordinate)
        }
    }
    private var selectedBike: Bike? {
        didSet {
            setButtons()
        }
    }
    @IBOutlet private var lightButton: RoundEdgeButton!
    @IBOutlet private var lockButton: RoundEdgeButton!
    @IBOutlet private var finishButton: RoundEdgeButton!
    @IBOutlet private var locationButton: RoundEdgeButton!

    @IBOutlet var actButtons: [RoundEdgeButton]!
    struct Input {
        let menu: () -> Void
    }
    var input: Input!

    @IBAction func locationTap(_ sender: Any) {
        guard let location = currentLocation else { return }
        mapView.centerToLocation(location)
    }
    @IBAction func finishTap(_ sender: Any) {

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
        actButtons.forEach { $0.imageView?.contentMode = .scaleAspectFit }
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
        guard let bike = selectedBike else { return }

        actButtons.forEach { $0.isHidden = false }
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
