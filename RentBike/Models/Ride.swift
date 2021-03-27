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

class RideStat: Mappable {
    var distanse: Int = 0
    var price: Int = 0
    var dateStart: Date?
    var dateEnd: Date?

    var title: String {
        return ""
    }
    

    required init?(map: Map) { }
    
    func mapping(map: Map) {
        dateStart <- (map["dateStart"], CustomDateFormatTransform(formatString: "yyyy.MM.dd HH:mm"))
        dateEnd <- (map["dateEnd"], CustomDateFormatTransform(formatString: "yyyy.MM.dd HH:mm"))
    }
}
