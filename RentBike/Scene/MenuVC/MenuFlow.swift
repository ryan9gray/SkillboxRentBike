//
//  MenuFlow.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.03.2021.
//

import UIKit

struct MenuFlow {

    let service: MenuService = .init()

    func rides(from: UIViewController) {
        let vc = RidesViewController.instantiate(fromStoryboard: .profile)
        vc.input = .init(getItems: getItems)
        from.present(vc, animated: true, completion: nil)
    }
    
    func wallet(from: UIViewController) {
        let vc = WalletViewController.instantiate(fromStoryboard: .profile)

        from.present(vc, animated: true, completion: nil)
    }

    func promo(from: UIViewController) {
        let vc = PromoViewController.instantiate(fromStoryboard: .profile)

        from.present(vc, animated: true, completion: nil)
    }

    func getItems(completion: @escaping ([String]) -> Void) {

    }
    
}
