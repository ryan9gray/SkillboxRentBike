//
//  NotificationService.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 06.04.2021.
//

import UIKit


class NotificationService {

    //static let shared = NotificationService()
    private var timer: Timer? = Timer()
    private let limit: CGFloat =  30.0

    func scheduleNotification(notificationType: String) {

        let content = UNMutableNotificationContent() // Содержимое уведомления

        content.title = notificationType
        content.body = "Водите осторожно"
        content.sound = UNNotificationSound.default
        content.badge = 1
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(limit), repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.sendPush()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func sendPush() {
        ApplicationFlow.shared.alertPresenter.show(alert: BasicNotificationAlert(text: "Водите осторожно"))
        NotificationCenter.default.post(name: NSNotification.Name.SendCoord, object: nil)
    }
}
