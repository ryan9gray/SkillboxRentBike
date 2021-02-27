//
//  NetworkManager.swift
//  Mems
//
//  Created by Evgeny Ivanov on 16.04.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import Alamofire


class NetworkManager {
	enum Status {
		case wifi
		case notReachable
		case notWifi
		case unknown
	}

	static let shared = NetworkManager()

	private init() {}

	let reachabilityManager = NetworkReachabilityManager(host: "www.google.com")

	func startNetworkReachabilityObserver() {
		reachabilityManager?.startListening(onUpdatePerforming: { (status) in
			switch status {

				case .notReachable:
					print("The network is not reachable")
					DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
						if !self.isConnectedToInternet {
                            ApplicationFlow.shared.showAlert("No ethernet")
							NotificationCenter.default.post(name: .NetworkReachability, object: Status.notReachable, userInfo: nil)
						}
					})
					return
				case .unknown :
					print("It is unknown whether the network is reachable")
					NotificationCenter.default.post(name: .NetworkReachability, object: Status.unknown, userInfo: nil)
				case .reachable(.ethernetOrWiFi):
					print("The network is reachable over the WiFi connection")
					NotificationCenter.default.post(name: .NetworkReachability, object: Status.wifi, userInfo: nil)

				case .reachable(.cellular):
					print("The network is reachable over the cellular connection")
					NotificationCenter.default.post(name: .NetworkReachability, object: Status.notWifi, userInfo: nil)
			}
		})
	}

	var isConnectedToInternet: Bool {
		reachabilityManager!.isReachable
	}

	var isConnectedToWifi: Bool {
		reachabilityManager!.isReachableOnEthernetOrWiFi
	}
}
