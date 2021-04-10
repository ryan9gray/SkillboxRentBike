//
//  LocationTracker.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 22.03.2021.
//

import Foundation
import CoreLocation

struct TenPMNotifications {
    static let UnsafeDistanceNotification = NSNotification.Name(rawValue: "UnsafeChildDistance")
    static let SafeDistanceNotification = NSNotification.Name(rawValue: "SafeChildDistance")
}

protocol LocationTrackerDelegate:class {
    func locationTrackerDidChangeAuthorizationStatus(_ locationTracker: LocationTracker)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
}

class LocationTracker: NSObject {

    static let shared = LocationTracker()
    let locationManager = CLLocationManager()
    weak var delegate: LocationTrackerDelegate?

    override init(){
        super.init()
        locationManager.delegate = self
    }

    func authorizeLocationTracking() {
        locationManager.requestAlwaysAuthorization()
    }

    fileprivate func startTrackingMysLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
    }
}

// MARK: CLLocationManager Delegate
extension LocationTracker: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(manager, didUpdateLocations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }

        if let location = manager.location {
            locationManager(manager, didUpdateLocations: [ location ])
        }

        startTrackingMysLocation()
        delegate?.locationTrackerDidChangeAuthorizationStatus(self)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        //fatalError()
    }
}
