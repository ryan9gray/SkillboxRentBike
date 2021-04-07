//
//  PushNotificationAlert.swift
//  Mems
//
//  Created by Evgeny Ivanov on 11.05.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import UIKit

/// Basic notification alert.
class PushNotificationAlert: NotificationAlert {
	var action: (() -> Void)?
	var hideAction: (() -> Void)?

	private(set) var view: UIView = UIView()
	private(set) var label: UILabel = UILabel()
	private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
	private var swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()

	private(set) var sound: String?

	var textColor: UIColor
	var backgroundColor: UIColor
	private var attributedText: NSAttributedString?

	init(
		title: String? = nil,
		text: String,
		action: (() -> Void)? = nil
	) {
		self.textColor = Style.Color.hint
		self.backgroundColor = Style.Color.red
		self.sound = nil
		self.action = action

		setupUI()
		setupContent(title: title, text: text)
		updateContent()
	}

	private func setupContent(title: String? = nil, text: String) {
		let attributedText = NSMutableAttributedString()

		var textStyle = Style.TextAttributes.whiteSubhedline
		textStyle[.foregroundColor] = textColor

		if let title = title {
			var titleStyle = Style.TextAttributes.whiteSubhedline
			titleStyle[.foregroundColor] = textColor
			textStyle[.paragraphStyle] = titleStyle[.paragraphStyle]

			attributedText.append("\(title)\n" <~ titleStyle)
		}
		attributedText.append(text <~ textStyle)

		self.attributedText = attributedText
	}

	/// Sets up UI.
	func setupUI() {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = backgroundColor
		view.clipsToBounds = true
		view.isUserInteractionEnabled = true
		view.layer.cornerRadius = 6
		view.layer.borderColor = Style.Color.hint.cgColor
		view.layer.borderWidth = 1

		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.setContentHuggingPriority(.required, for: .vertical)
		label.textColor = textColor
		view.addSubview(label)

		let line = HairLineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		line.bottomRight = true
		view.addSubview(line)

		let margin = Style.Margins.default

		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: view.topAnchor, constant: margin).with(priority: .required - 1),
			label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin).with(priority: .required - 1),
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).with(priority: .required - 1),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).with(priority: .required - 1),
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
