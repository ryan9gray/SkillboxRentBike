//
//  Profile.swift
//  Mems
//
//  Created by Eugene Ivanov on 26.11.2019.
//  Copyright © 2019 Eugene Ivanov. All rights reserved.
//
import ObjectMapper

final class Profile: Mappable  {
	static var current: Profile? = AppCacher.mappable.getObject(of: Profile.self) {
		didSet {
			NotificationCenter.default.post(name: NSNotification.Name.ProfileDidChanged, object: current)
		}
	}

	static var isAuthorized: Bool {
		current != nil
	}

	var id: String = ""
    var profileId: String = ""
    var token: String = ""

	var email: String = ""
	var phone: String = ""
	var avatar: String = ""
    var about: String = ""
    var username: String = ""

	required init?(map: Map) { }

	func mapping(map: Map) {
		id <- map["userId"]
        profileId <- map["profileId"]
        token <- map["token"]
        about <- map["about"]
        username <- map["username"]
	}

	func save() {
		AppCacher.mappable.saveObject(self)
	}
}
