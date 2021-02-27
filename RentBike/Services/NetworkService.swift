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

	static let baseUrl = "http://85.119.146.20:3000/"

    func getProfile(complition: @escaping (String?) -> Void) {
        guard let id = Profile.current?.profileId else { return }

        AF.request(NetworkService.baseUrl + "api/v1/profile/\(id)").responseJSON { response in
            debugPrint(response)
            guard
                let data = response.data,
                let avatar = JSON(data)["info"]["avatar"].string
            else { return complition(nil) }

            Profile.current?.username = JSON(data)["info"]["username"].string ?? ""
            Profile.current?.about = JSON(data)["info"]["about"].string ?? ""
            Profile.current?.avatar = avatar
            complition(avatar)
        }
    }

    func updateProfile() {

    }

    func upload(
        image: UIImage?,
        completion: @escaping (Result<Void>) -> Void,
        onProgress: @escaping (Double) -> Void
    ) {
        guard
            let id = Profile.current?.profileId
        else { return }

        AF.upload(
            multipartFormData: { multipartFormData in
                if let jpegData = image?.resizeWith()?.jpegData(compressionQuality: 1.0) {
                    multipartFormData.append(Data(jpegData), withName: "avatar", fileName: "form-data", mimeType: "image/png")
                }
            },
            to: NetworkService.baseUrl + "api/v1/profile/\(id)",
            method: .post,
            requestModifier: { request in
                let body = try? JSONEncoder().encode(ProfileResponse(username: "r9g", about: "U know who i am"))
                request.httpBody = body
            }
        ).responseJSON { response in
            debugPrint(response)

        }
    }

    struct ProfileResponse: Codable {
        let username: String?
        let about: String?
    }
}
