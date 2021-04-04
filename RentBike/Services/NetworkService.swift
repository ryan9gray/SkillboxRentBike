//
//  NetworkService.swift
//  SkillBoxTester
//
//  Created by Evgeny Ivanov on 22.08.2020.
//  Copyright © 2020 Evgeny Ivanov. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

/// Больно, но быстро (название твоего домашнего видео)
class NetworkService {

	static let shared = NetworkService()


    func getProfile(complition: @escaping (Profile?) -> Void) {
        AF.request(Api.profile.url, headers: ["token": Profile.tokenOrEmpty]).responseJSON { response in
            debugPrint(response)
            guard let data = response.data
            else { return complition(nil) }

            let json = JSON(data)["info"]
            if let profile = Mapper<Profile>().map(JSONString: json.description) {
                Profile.current = profile
                Profile.current?.save()
            }
        }
    }

    func updateProfile() {

    }
    func update(completion: @escaping (Profile?) -> Void) {
        guard let profile = Profile.current else {
            return completion(nil)
        }
        let stringURL = Api.profile.url
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        let body = try? JSONEncoder().encode(profile.update)
        request.httpBody = body

        AF.request(request)
            .responseJSON { response in
                print(response)
                switch response.result {
                    case .success(let data):
                        let json = JSON(data)["info"]
                        let profile = Mapper<Profile>().map(JSONString: json.description)
                        Profile.current = profile
                        Profile.current?.save()
                        completion(profile)
                    case .failure(let error):
                        print(error)
                        completion(nil)
                }

            }
    }

    func move(coordinate: Cordinate) {
        let stringURL = Api.profile.url
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        let body = try? JSONEncoder().encode(coordinate)
        request.httpBody = body

        AF.request(request)
            .responseJSON { response in
                print(response)
                switch response.result {
                    case .success:
                        break
                    case .failure(let error):
                        print(error)
                }
            }
    }

    struct Cordinate: Codable {
        let latitude: Double
        let longitude: Double
    }

}
enum Api: String {
    static let baseUrl = "http://77.223.116.18:3000/api/v1/"

    case auth = "users/login"
    case rides = "rides"
    case bikes = "bikes"
    case profile = "profile"
	case startRide = "ride/start"
    case finishRide = "ride/finish"
    case move = "ride/move"
    case startBook = "book/start"
    case finishBook = "book/finish"
    case wallet = "wallet"


    var url: String {
        return Api.baseUrl + self.rawValue
    }
}
