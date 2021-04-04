//
//  MenuService.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.03.2021.
//

import Foundation
import Alamofire

struct MenuService {

    func getRides(completion: ([Ride]) -> Void) {
        completion(Profile.current?.rides ?? [])
    }

    func sendPromo(code: String, completion: @escaping (Bool) -> Void) {
        let stringURL = Api.wallet.url
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token", forHTTPHeaderField: Profile.tokenOrEmpty)

        let body = try? JSONEncoder().encode(Promo(promo: code))
        request.httpBody = body

        AF.request(request)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                    case .success:
                    completion(true)
                    case .failure(let error):
                        print(error)
                        completion(false)
                }
            }
    }

    struct Promo: Codable {
        let promo: String
    }
}
