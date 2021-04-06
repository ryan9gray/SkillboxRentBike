//
//  MenuViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 22.03.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MenuDisplayLogic: class {
    
}

class MenuViewController: UIViewController, MenuDisplayLogic {
    var interactor: MenuBusinessLogic?
    var router: (MenuRoutingLogic & MenuDataPassing)?

    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var walletLabel: UILabel!
    @IBOutlet var calLabel: UILabel!
    @IBOutlet var distansLabel: UILabel!
    @IBOutlet var ridesLabel: UILabel!

    @IBAction func ridesTap(_ sender: Any) {
        router?.openRide()
    }
    @IBAction func walletTap(_ sender: Any) {
        router?.openWallet()
    }
    @IBAction func logoutTap(_ sender: Any) {
        interactor?.logout()
    }
    @IBAction func promoCodeTap(_ sender: Any) {
        router?.openPromo()
    }
    @IBAction func faqTap(_ sender: Any) {

    }
    
    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        let viewController = self
        let interactor = MenuInteractor()
        let presenter = MenuPresenter()
        let router = MenuRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileDidChanged),
            name: NSNotification.Name.ProfileDidChanged,
            object: nil
        )
        profileDidChanged()
        
    }

    @objc func profileDidChanged() {
        if let profile = Profile.current {
            updateLabels(profile: profile)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        interactor?.getProfile(complition: { [weak self] profile in
            guard let self = self, let profile = profile else { return }

            self.updateLabels(profile: profile)
        })
    }

    func updateLabels(profile: Profile) {
        avatarImageView.setImageWithSD(from: profile.avatar)
        walletLabel.text = "Кошелек \(profile.balance)"
        calLabel.text = "Калории \(profile.calories)"
        distansLabel.text = "Пробег \(profile.distance)"
        ridesLabel.text = "Поездки \(profile.rides.count)"
    }

}
