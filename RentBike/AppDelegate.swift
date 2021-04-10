//
//  AppDelegate.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.02.2021.
//

import UIKit
import SDWebImage
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureApp()
        window?.makeKeyAndVisible()
        setuoGoogle()
        configureApp()
        ApplicationFlow.shared.start()
        return true
    }

    fileprivate func configureApp() {
        NetworkManager.shared.startNetworkReachabilityObserver()
        SDImageCache.shared.config.maxDiskSize = 100 * 1024 * 1024
        SDImageCache.shared.config.maxMemoryCost = 15 * 1024 * 1024
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AppDelegate.rotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if let er = error{
                let log = "requestAuthorization error \(er)"
                print(log)
            }
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }

    func setuoGoogle() {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            if UIApplication.topViewController() is WalletViewController {
                fatalError("Bug rotation")
            }
        }

        if UIDevice.current.orientation.isPortrait {
            print("Portrait")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if UIApplication.topViewController() is PromoViewController {
            fatalError()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Background")
    }
    func applicationWillTerminate(_ application: UIApplication) {
        print("Terminate")
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Foreground")
    }
    // Handle remote notification registration.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){

    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")

    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
    }
}
