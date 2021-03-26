//
//  SocketService.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 25.03.2021.
//

import SwiftSocket

class SwiftSocketService {
    let client = TCPClient(address: "www.apple.com", port: 80)

    func foo() {
        switch client.connect(timeout: 1) {
            case .success:
                switch client.send(string: "GET / HTTP/1.0\n\n" ) {
                    case .success:
                        guard let data = client.read(1024*10) else { return }

                        if let response = String(bytes: data, encoding: .utf8) {
                            print(response)
                        }
                    case .failure(let error):
                        print(error)
                }
            case .failure(let error):
                print(error)
        }
    }
}
