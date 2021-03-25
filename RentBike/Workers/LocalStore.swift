//
//  LocalStore.swift
//  Mems
//
//  Created by Evgeny Ivanov on 02.12.2019.
//  Copyright © 2019 Eugene Ivanov. All rights reserved.
//

import Foundation
import CoreLocation

struct LocalStore {
	fileprivate static let userDefaults = UserDefaults.standard

	@Storage(userDefaults: userDefaults, key: "notFirstLaunch", defaultValue: false)
	static var notFirstLaunch: Bool

    @Storage(userDefaults: userDefaults, key: "safeDistance", defaultValue: false)
    static var safeDistance: Bool
}

@propertyWrapper
struct Storage<T> {
	private let key: String
	private let defaultValue: T
	let userDefaults: UserDefaults

	init(userDefaults: UserDefaults = UserDefaults.standard, key: String, defaultValue: T) {
		self.key = key
		self.defaultValue = defaultValue
		self.userDefaults = userDefaults
	}

	var wrappedValue: T {
		get {
			userDefaults.object(forKey: key) as? T ?? defaultValue
		}
		set {
			userDefaults.set(newValue, forKey: key)
		}
	}
}
class BikeProfile {

    private static let homeLatitudeKey = "homeLatitude"
    private class var homeLatitude: CLLocationDegrees? {
        get {
            return UserDefaults.standard.object(forKey: homeLatitudeKey) as? CLLocationDegrees
        }
        set {
            UserDefaults.standard.set(newValue, forKey: homeLatitudeKey)
        }
    }

    private static let homeLongitudeKey = "homeLongitude"
    private class var homeLongitude: CLLocationDegrees? {
        get{
            return UserDefaults.standard.object(forKey: homeLongitudeKey) as? CLLocationDegrees
        }
        set {
            UserDefaults.standard.set(newValue, forKey: homeLongitudeKey)
        }
    }

    private static let homeLocationKey = "homeLocation"
    class var homeLocation: CLLocation? {
        get {
            guard let latitude = homeLatitude,
                  let longitude = homeLongitude
            else { return nil }

            return CLLocation(latitude: latitude, longitude: longitude)
        }
        set {
            homeLatitude = newValue?.coordinate.latitude
            homeLongitude = newValue?.coordinate.longitude
        }
    }

    static let maxDistanse: CLLocationDistance = .init(2000)
    private static let safeDistanceKey = "safeDistance"
    class var safeDistanceFromHome: CLLocationDistance? {
        get {
            return UserDefaults.standard.double(forKey: safeDistanceKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: safeDistanceKey)
        }
    }
}
