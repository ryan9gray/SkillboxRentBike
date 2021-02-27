//
//  MainTabBarController.swift
//  Mems
//
//  Created by Evgeny Ivanov on 29.11.2019.
//  Copyright © 2019 Eugene Ivanov. All rights reserved.
//
import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        let appearance = UITabBarItem.appearance()
        appearance.setTitleTextAttributes(Style.TextAttributes.regular, for: .normal)
        appearance.setTitleTextAttributes(Style.TextAttributes.tabSelected, for: .selected)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.isHidden = false
    }
    
    func setupTabBar() {
        tabBar.barTintColor = Style.TextAttributes.backColor
        //tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = Style.TextAttributes.backColor
        tabBar.shadowImage = UIImage()
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -5)
        tabBar.layer.shadowOpacity = 0.05
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    // MARK: UITabbar Delegate

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        return true
    }
}
