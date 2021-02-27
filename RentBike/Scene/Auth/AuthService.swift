//
//  AuthService.swift
//  SkillBoxTester
//
//  Created by Evgeny Ivanov on 23.08.2020.
//  Copyright © 2020 Evgeny Ivanov. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

struct AuthService {

    func logIn(end: Endpoint, params: Body, completion: @escaping (Profile?) -> Void) {
        let stringURL = NetworkService.baseUrl + "api/v1/users/" + end.rawValue
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = try? JSONEncoder().encode(params)//JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
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

    enum Endpoint: String {
        case login = "login"
        case signup = "register"
    }

    enum AuthType: String {
        case google
        case email
    }

    struct Body: Encodable {
        internal init(type: String, creds: AuthService.Cred) {
            self.type = type
            self.creds = creds
        }
        
        let type: String
        let creds: Cred
        let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    struct Cred: Encodable {
        let gtoken: String
        let login: String
        let password: String

        internal init(gtoken: String = "", login: String = "", password: String = "") {
            self.gtoken = gtoken
            self.login = login
            self.password = password
        }
    }
}
