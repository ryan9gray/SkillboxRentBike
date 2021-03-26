//
//  Ride.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 26.03.2021.
//

import ObjectMapper

struct Ride {
    var inProgress: Bool = false
    var lightOn: Bool = false
    var isLock = true

}

struct RideStat {
    var distanse: Int = 0
}
