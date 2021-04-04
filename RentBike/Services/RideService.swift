//
//  RideService.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 02.04.2021.
//

import Alamofire
import SwiftyJSON
import ObjectMapper

struct RideService {


    func getBike(id: Int, completion: @escaping (Bike?) -> Void) {
        let stringURL = Api.bikes.url + "/\(id)"
        let url = URL(string: stringURL)
        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        AF.request(request)
            .responseJSON { response in
                print(response)
                switch response.result {
                    case .success(let data):
                        let json = JSON(data)["info"]
                        let bike = Mapper<Bike>().map(JSONString: json.description)
                        completion(bike)
                    case .failure(let error):
                        print(error)
                        completion(nil)
                }
            }
    }
    func getNearBike(completion: @escaping (Bike?) -> Void) {
        let stringURL = Api.bikes.url
        let url = URL(string: stringURL)
        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        AF.request(request)
            .responseJSON { response in
                print(response)
                switch response.result {
                    case .success(let data):
                        let json = JSON(data)["info"]
                        let bike = Mapper<Bike>().map(JSONString: json.description)
                        completion(bike)
                    case .failure(let error):
                        print(error)
                        completion(nil)
                }
            }
    }

    func bikeChange(_ bike: BikeChange, id: Int, completion: @escaping (Bike?) -> Void) {
        let stringURL = Api.bikes.url + "/\(id)"
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        let body = try? JSONEncoder().encode(bike)
        request.httpBody = body

        AF.request(request)
            .responseJSON { response in
                print(response)
                switch response.result {
                    case .success(let data):
                        let json = JSON(data)["info"]
                        let bike = Mapper<Bike>().map(JSONString: json.description)
                        completion(bike)
                    case .failure(let error):
                        print(error)
                }
            }
    }

    func book(id: Int, start: Bool) {
        let stringURL = start ? Api.startBook.url : Api.finishBook.url
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        let body = try? JSONEncoder().encode(BikeRequest.init(bikeId: id))
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

    func rideStart(id: Int) {
        let stringURL = Api.startRide.url
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        let body = try? JSONEncoder().encode(BikeRequest.init(bikeId: id))
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

    func rideFinish(_ ride: RideFinish) {
        let stringURL = Api.finishRide.url
        let url = URL(string: stringURL)

        var request = URLRequest(url: url!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Profile.tokenOrEmpty, forHTTPHeaderField: "token")

        let body = try? JSONEncoder().encode(ride)
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


    struct BikeRequest: Codable {
        let bikeId: Int
    }

    struct RideFinish: Codable {
        let bikeId: Int
        let distance: Int
    }

    struct BikeChange: Codable {
        let lightOn: Bool
        let isUnlock: Bool
    }
}
