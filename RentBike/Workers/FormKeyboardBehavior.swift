//
//  FormKeyboardBehavior.swift
//  Mems
//
//  Created by Evgeny Ivanov on 13.04.2020.
//  Copyright © 2020 Eugene Ivanov. All rights reserved.
//

import Foundation
import UIKit

/// Form keyboard behavior.
class FormKeyboardBehavior {
	var defaultInsets: UIEdgeInsets = .zero
	var scrollView: UIScrollView! {
		didSet {
			defaultInsets = scrollView.contentInset
			configureScrollView()
		}
	}
	var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .interactive {
		didSet {
			configureScrollView()
		}
	}

	/// Adds keyboard notification handlers. Should be called when showing view controller.
	func addKeyboardNotifications() {
		configureScrollView()

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardSizeChanged),
											   name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	/// Removes keyboard notification handlers. Should be called when hiding view controller.
	func removeKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	/// Callback for keyboard size changed notification.
	@objc func keyboardSizeChanged(_ notification: Notification) {
		guard
			let userInfo = notification.userInfo,
			let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

		let frameInView = scrollView.convert(frame, from: nil)
		let bottomInset = max(scrollView.bounds.maxY - frameInView.minY, 0)

		var insets = defaultInsets
		insets.bottom = max(insets.bottom, bottomInset)

		scrollView.contentInset = insets
		scrollView.scrollIndicatorInsets = insets
	}

	private func configureScrollView() {
		scrollView.keyboardDismissMode = keyboardDismissMode
	}
}
