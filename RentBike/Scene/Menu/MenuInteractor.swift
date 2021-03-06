//
//  MenuInteractor.swift
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
import Firebase
import GoogleSignIn

protocol MenuBusinessLogic {
    func getProfile(complition: @escaping (Profile?) -> Void)
    func logout()
}

protocol MenuDataStore {
    
}

class MenuInteractor: MenuBusinessLogic, MenuDataStore {
    var presenter: MenuPresentationLogic?    

    func getProfile(complition: @escaping (Profile?) -> Void) {
        NetworkService.shared.getProfile(complition: complition)
    }

    func logout() {
        Profile.current = nil
        AppCacher.mappable.removeValue(of: Profile.self)
        ViewHierarchyWorker.resetAppForAuthentication()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
