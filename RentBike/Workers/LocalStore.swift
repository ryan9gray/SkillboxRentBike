//
//  LocalStore.swift
//  Mems
//
//  Created by Evgeny Ivanov on 02.12.2019.
//  Copyright © 2019 Eugene Ivanov. All rights reserved.
//

import UIKit

struct LocalStore {
	fileprivate static let userDefaults = UserDefaults.standard

	@Storage(userDefaults: userDefaults, key: "notFirstLaunch", defaultValue: false)
	static var notFirstLaunch: Bool


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
