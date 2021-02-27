//
//  Notification.swift
//  iHAQ
//
//  Created by Evgeny Ivanov on 25.06.2020.
//  Copyright © 2020 r9g. All rights reserved.
//

import Foundation

extension Notification.Name {
	public static let BadgeValueChanged = Notification.Name(rawValue: "BadgeValueChanged")
	public static let BadgeDidRecivePush = Notification.Name(rawValue: "BadgeDidRecivePush")
	public static let ProfileDidChanged = Notification.Name(rawValue: "ProfileDidChanged")
    public static let BasketDidChanged = Notification.Name(rawValue: "BasketDidChanged")

	public static let NetworkReachability = Notification.Name("NetworkReachability")
}
