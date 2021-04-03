//
//  Ride.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 26.03.2021.
//

import ObjectMapper

class Bike: Mappable {
    var lightOn: Bool = false
    var isUnlock = false

    var status: Status = .free

    enum Status: Int {
		case free = 0
        case booked = 1
        case inProgress = 2
    }
    
    init() { }

    required init?(map: Map) {}

    func mapping(map: Map) {
        status <- (map["status"], EnumTransform<Status>())
        lightOn <- map["lightOn"]
        isUnlock <- map["isLock"]
    }
}

class Ride: Mappable {
    var distance: Int = 0
    var price: Int = 0
    var dateStart: TimeInterval = 0
    var dateEnd: TimeInterval = 0

    init() { }

    required init?(map: Map) { }
    
    func mapping(map: Map) {
        dateStart <- map["dateStart"]
        dateEnd <- map["dateEnd"]
        distance <- map["distance"]
        price <- map["price"]
    }
}

class BikeState {
    var sec: Int = 0
    
}
