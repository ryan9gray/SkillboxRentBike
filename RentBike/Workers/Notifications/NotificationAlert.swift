//
//  NotificationAlert.swift
//  Mems
//
//  Created by Evgeny Ivanov on 14.04.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import UIKit

/// Notification alert identity.
struct NotificationAlertIdentity: Hashable {
	var id: String
}

/// Notification alert protocol.
protocol NotificationAlert: class {
	var sound: String? { get }
	var view: UIView { get }
	var hideAction: (() -> Void)? { get set }
}
