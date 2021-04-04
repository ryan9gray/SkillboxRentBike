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
        vc.output = .init(promocode: postPromo)
        from.present(vc, animated: true, completion: nil)
    }

    func postPromo(text: String, completion: @escaping (Bool) -> Void) {
        service.sendPromo(code: text) { bool in
            completion(bool)
        }
    }

    func getItems(completion: @escaping ([String]) -> Void) {
        service.getRides { rides in

            let titles = rides.map { ride -> String in
                let start = Date(timeIntervalSince1970: ride.dateStart)
                let end = Date(timeIntervalSince1970: ride.dateEnd)
                return [start.longDate, start.hours, end.hours, "\(ride.price)р"].joined(separator: " / ")
            }
            completion(titles)
        }
    }
    
}
