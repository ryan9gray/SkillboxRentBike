//
//  AnonNotificationAlert.swift
//  Mems
//
//  Created by Evgeny Ivanov on 01.05.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import UIKit

/// Basic notification alert.
class AnonNotificationAlert: NotificationAlert {
	init() {
		self.sound = nil
		self.action = {
			let alert = UIAlertController(title: nil, message: "do_u_won_authorize".localized, preferredStyle: .alert)
			alert.modalPresentationStyle = .popover
			alert.addAction(UIAlertAction(title: "yes".localized, style: .default, handler: { _ in
				ViewHierarchyWorker.resetAppForAuthentication()
			}))
			alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
			//alert.applyStyle()
			UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
		}
		setupUI()
		setupContent(message: "error_common_anon".localized)
		updateContent()
	}

	var action: (() -> Void)?
	var hideAction: (() -> Void)?

	let view: UIView = UIView()
	let label: UILabel = UILabel()
	private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
	private var swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()

	private(set) var sound: String?

	private let warningIcon = UIImageView()
	private var attributedText: NSAttributedString?


	private func setupGestures() {
		tapGesture.addTarget(self, action: #selector(tap))
		view.addGestureRecognizer(tapGesture)

		swipeGesture.direction = .up
		swipeGesture.addTarget(self, action: #selector(swipe))
		view.addGestureRecognizer(swipeGesture)
	}

	func setupContent(message: String) {
		self.attributedText = message <~ Style.TextAttributes.whiteSubhedline
	}

	func setupUI() {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Style.Color.red
		view.clipsToBounds = true
		view.isUserInteractionEnabled = true
		view.layer.cornerRadius = 6
		view.layer.borderColor = Style.Color.hint.cgColor
		view.layer.borderWidth = 1

		warningIcon.image = UIImage(named: "icMaskotAngry")
		warningIcon.translatesAutoresizingMaskIntoConstraints = false
		warningIcon.contentMode = .scaleAspectFit
		view.addSubview(warningIcon)
		label.textAlignment = .left
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.setContentHuggingPriority(.required, for: .vertical)
		view.addSubview(label)

		let line = HairLineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		line.bottomRight = true
		view.addSubview(line)

		NSLayoutConstraint.activate([
			warningIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			warningIcon.centerYAnchor.constraint(equalTo: label.centerYAnchor),
			warningIcon.heightAnchor.constraint(equalToConstant: 50).with(priority: .required - 1),
			label.leadingAnchor.constraint(equalTo: warningIcon.trailingAnchor, constant: 8),
			label.topAnchor.constraint(equalTo: view.topAnchor, constant: 22).with(priority: .required - 1),
			label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -22).with(priority: .required - 1),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).with(priority: .required - 1),
			label.heightAnchor.constraint(equalToConstant: 50).with(priority: .required - 1),
			line.heightAnchor.constraint(equalToConstant: 1),
			line.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
		tapGesture.addTarget(self, action: #selector(tap))
		view.addGestureRecognizer(tapGesture)
		swipeGesture.direction = .up
		swipeGesture.addTarget(self, action: #selector(swipe))
		view.addGestureRecognizer(swipeGesture)
	}

	/// Tap handler.
	@objc private func tap() {
		hideAction?()
		action?()
	}

	/// Swipe handler.
	@objc private func swipe() {
		hideAction?()
	}

	/// Updates content.
	private func updateContent() {
		label.attributedText = attributedText
	}
}
