//
//  WindowAlertPresenter.swift
//  Mems
//
//  Created by Evgeny Ivanov on 14.04.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import UIKit

enum NotificationAlertStyle {
	case green
	case red
	case white
}

protocol AlertPresenter {
	/// Shows an alert.
	/// - parameter alert: alert to show
	/// - returns: identity that can be used to hide alert
	@discardableResult
	func show(alert: NotificationAlert) -> NotificationAlertIdentity

	/// Hides an alert.
	/// - parameter id: notification alert identity that is returned when alert is being shown
	func hide(id: NotificationAlertIdentity)

	/// Hides all alerts.
	func hideAll()
}


/// Alert presenter that uses separate window to show alerts.
class WindowAlertPresenter: AlertPresenter {
	var maximumAlerts: Int {
		get { controller.maximumAlerts }
		set { controller.maximumAlerts = newValue }
	}

	var showDuration: TimeInterval {
		get { controller.showDuration }
		set { controller.showDuration = newValue }
	}

	var animationDuration: TimeInterval {
		get { controller.animationDuration }
		set { controller.animationDuration = newValue }
	}

	private var controller: AlertPresenterViewController = AlertPresenterViewController()
	private var window: AlertWindow = AlertWindow()

	init() {
		controller.soundPlayer = SystemSoundPlayer()

		window.rootViewController = controller
		window.onHitTest = { point, event in
			self.controller.hitTest(point, with: event)
		}

		controller.onShow = { [weak self] in
			self?.window.isHidden = false
		}
		controller.onHide = { [weak self] in
			self?.window.isHidden = true
		}
	}

	func show(alert: NotificationAlert) -> NotificationAlertIdentity {
		controller.show(alert: alert)
	}

	func hide(id: NotificationAlertIdentity) {
		controller.hide(id: id)
	}

	func hideAll() {
		controller.hideAll()
	}
}

/// Window that shows alerts.
private class AlertWindow: UIWindow {
	var onHitTest: (_ point: CGPoint, _ event: UIEvent?) -> UIView? = { _, _  in nil }

	init() {
		super.init(frame: UIScreen.main.bounds)

		windowLevel = UIWindow.Level.statusBar - 1
		backgroundColor = .clear
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		onHitTest(point, event)
	}
}

/// View Controller for the alert presenter.
private class AlertPresenterViewController: UIViewController {
	var maximumAlerts: Int = 1

	var onShow: (() -> Void)?
	var onHide: (() -> Void)?

	private var contentView: UIStackView = UIStackView()
	private var statusBarView: UIView = UIView()

	var soundPlayer: SoundPlayer!

	var showDuration: TimeInterval = 5
	var animationDuration: TimeInterval = 0.3
	var startStackViewIndex: Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .clear
		view.addSubview(contentView)

		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.clipsToBounds = true
		contentView.axis = .vertical
		contentView.distribution = .fill
		contentView.alignment = .fill

		let fakeView = UIView()
		fakeView.translatesAutoresizingMaskIntoConstraints = false
		fakeView.backgroundColor = .white
		contentView.addArrangedSubview(fakeView)

		statusBarView.translatesAutoresizingMaskIntoConstraints = false
		statusBarView.backgroundColor = .white
		statusBarView.isHidden = true
		contentView.addArrangedSubview(statusBarView)

		startStackViewIndex = contentView.arrangedSubviews.count

		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
			contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
			contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
			fakeView.heightAnchor.constraint(equalToConstant: 0),
			statusBarView.topAnchor.constraint(equalTo: view.topAnchor).with(priority: .required - 1),
			statusBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).with(priority: .required - 1),
		])

		view.layoutIfNeeded()
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
	override var shouldAutorotate: Bool { true }

	/**
	Tests whether controller should interact with the tap at this point.
	- parameters:
	- point: tap point
	- with: event that contains this point
	- returns: UIView that should receive the tap or nil it there is no such view
	*/
	func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		contentView.hitTest(point, with: event)
	}

	// MARK: - Timer

	/// Starts alert hide timer.
	private func startTimer() -> Timer {
		let timer = Timer(timeInterval: showDuration, target: self, selector: #selector(onTimer), userInfo: nil, repeats: false)
		RunLoop.main.add(timer, forMode: .default)
		RunLoop.main.add(timer, forMode: .tracking)
		return timer
	}

	/// Alert hide timer handler.
	@objc private func onTimer() {
		hideFirstAlert()
	}

	// MARK: - Presentation

	/// Alert data model.
	private class AlertData {
		var id: NotificationAlertIdentity
		var alert: NotificationAlert
		var timer: Timer?

		init(id: NotificationAlertIdentity, alert: NotificationAlert, timer: Timer?) {
			self.id = id
			self.alert = alert
			self.timer = timer
		}

		/// Clear and remove alert timer.
		func clear() {
			timer?.invalidate()
			alert.hideAction = nil
		}
	}

	private var alerts: [AlertData] = []

	/**
	Shows notification alert.
	- parameter alert: notification alert to show
	- returns: notification alert identity that can be used to hide the alert
	*/
	func show(alert: NotificationAlert) -> NotificationAlertIdentity {
		let alertId = NotificationAlertIdentity(id: UUID().uuidString)
		if alerts.isEmpty {
			onShow?()
		}

		var normalAlerts = alerts

		var alertsForDismiss: Array<AlertData>.SubSequence = []
		if maximumAlerts > 0 && normalAlerts.count >= maximumAlerts {
			let dropCount = normalAlerts.count - maximumAlerts + 1
			alertsForDismiss = normalAlerts.prefix(upTo: dropCount)
			normalAlerts = Array(normalAlerts.dropFirst(dropCount))
			alertsForDismiss.forEach { $0.clear() }
		}

		let timer = startTimer()
		let alertData = AlertData(id: alertId, alert: alert, timer: timer)

		alert.view.isHidden = true

		normalAlerts.append(alertData)
		contentView.insertArrangedSubview(alert.view, at: startStackViewIndex)

		alerts = normalAlerts

		alert.hideAction = { [weak self, weak alertData] in
			alertData.with { self?.hide(alertData: $0) }
		}

		UIView.animate(
			withDuration: animationDuration,
			animations: {
				self.statusBarView.backgroundColor = .clear//self.alerts[0].alert.view.backgroundColor
				self.statusBarView.isHidden = false

				alertsForDismiss.forEach { $0.alert.view.isHidden = true }
				alert.view.isHidden = false
			},
			completion: { _ in
				alert.sound.with(self.soundPlayer.play)
				alertsForDismiss.forEach { $0.alert.view.removeFromSuperview() }
			}
		)
		return alertData.id
	}

	/// Hides notification alert using the identity that was created in the show method.
	func hide(id: NotificationAlertIdentity) {
		alerts.first { $0.id == id }.with(hide)
	}

	/// Hides notification by the notification model.
	private func hide(alertData: AlertData) {
		alertData.clear()

		alerts = alerts.filter { $0 !== alertData }

		UIView.animate(
			withDuration: animationDuration,
			animations: {
				alertData.alert.view.isHidden = true

				if self.alerts.isEmpty {
					self.statusBarView.isHidden = true
					self.statusBarView.backgroundColor = .clear
				} else {
					self.statusBarView.backgroundColor = .clear//self.alerts[0].alert.view.backgroundColor
				}
			},
			completion: { _ in
				alertData.alert.view.removeFromSuperview()

				if self.alerts.isEmpty {
					self.onHide?()
				}
			}
		)
	}

	/// Hides first alert in the alerts list.
	private func hideFirstAlert() {
		guard let alertData = alerts.first else { return }

		hide(alertData: alertData)
	}

	func hideAll() {
		guard !alerts.isEmpty else { return }

		UIView.animate(
			withDuration: animationDuration,
			animations: {
				self.alerts.forEach { data in
					data.alert.view.isHidden = true
				}

				self.statusBarView.isHidden = true
				self.statusBarView.backgroundColor = .white
			},
			completion: { _ in
				self.alerts.forEach { data in
					data.alert.view.removeFromSuperview()
					data.clear()
				}
				self.alerts = []
				self.onHide?()
			}
		)
	}
}
