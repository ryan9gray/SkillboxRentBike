//
//  Profile.swift
//  Mems
//
//  Created by Eugene Ivanov on 26.11.2019.
//  Copyright © 2019 Eugene Ivanov. All rights reserved.
//
import ObjectMapper
import CoreLocation

final class Profile: Mappable  {
	static var current: Profile? = AppCacher.mappable.getObject(of: Profile.self) {
		didSet {
			NotificationCenter.default.post(name: NSNotification.Name.ProfileDidChanged, object: current)
		}
	}

	static var isAuthorized: Bool {
		current != nil
	}

    static var tokenOrEmpty: String {
        return current?.token ?? ""
    }

	var id: String = ""
	var avatar: String = ""
    var balance: Int = 0
    var distance: Int = 0
    var calories: Int = 0
    var rides: [Ride] = []
    var token: String = ""
    var latitude: Double?
    var longitude: Double?
    var lastBike: Bike?

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return .init(latitude: latitude, longitude: longitude)
    }

    var update: ProfileUpdate {
        return .init(calories: calories, balance: balance, distance: distance, avatar: avatar, latitude: longitude, longitude: longitude)
    }

	required init?(map: Map) { }

	func mapping(map: Map) {
		id <- map["id"]
        token <- map["token"]
        avatar <- map["avatar"]
        balance <- map["balance"]
        distance <- map["distance"]
        rides <- map["rides"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        lastBike <- map["lastBike"]
	}

	func save() {
		AppCacher.mappable.saveObject(self)
	}
}

struct ProfileUpdate: Codable {
    let calories: Int
    let balance: Int
    let distance: Int
    let avatar: String?
    let latitude: Double?
    let longitude: Double?
}
