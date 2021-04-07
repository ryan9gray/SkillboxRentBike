//
//  ErrorNotificationAlert.swift
//  Mems
//
//  Created by Evgeny Ivanov on 14.04.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import UIKit

/// Alert that displays error notifications.
final class ErrorNotificationAlert: NotificationAlert {
	var action: (() -> Void)?
	var hideAction: (() -> Void)?

	let view: UIView = UIView()
	let label: UILabel = UILabel()
	private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
	private var swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()

	private(set) var sound: String?

	private let warningIcon = UIImageView()
	private var attributedText: NSAttributedString?

	static func errorMessage(error: Error?, combined: Bool, text: String?) -> String {
		var message: String
		let errorText = (error as? BackendError)?.errorDescription
		if combined, let errorText = errorText {
			message = (text ?? "error_unknown_error".localized + "\n" + errorText)
		} else {
			message = errorText ?? text ?? "error_unknown_error".localized
		}
		return message
	}

	init(
		error: Error? = nil,
		text: String? = nil,
		combined: Bool = false,
		action: (() -> Void)? = nil
	) {
		let message = ErrorNotificationAlert.errorMessage(error: error, combined: combined, text: text)
		self.action = action

		setupUI()
		setupContent(message: message)
		updateContent()
		setupGestures()
	}

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
		view.layer.borderColor = Style.Color.nevada.cgColor
		view.layer.borderWidth = 1

		warningIcon.translatesAutoresizingMaskIntoConstraints = false
		warningIcon.image = nil
		view.addSubview(warningIcon)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.setContentHuggingPriority(.required, for: .vertical)
		view.addSubview(label)

		let line = HairLineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		line.bottomRight = true
		view.addSubview(line)

		NSLayoutConstraint.activate([
			warningIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
			warningIcon.bottomAnchor.constraint(equalTo: label.firstBaselineAnchor),
			warningIcon.widthAnchor.constraint(equalToConstant: 0),
			label.leadingAnchor.constraint(equalTo: warningIcon.trailingAnchor, constant: 8),
			label.topAnchor.constraint(equalTo: view.topAnchor, constant: 22).with(priority: .required - 1),
			label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -22).with(priority: .required - 1),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).with(priority: .required - 1),

			line.heightAnchor.constraint(equalToConstant: 1),
			line.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
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
