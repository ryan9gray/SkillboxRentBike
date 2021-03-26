//
//  PromoViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 26.03.2021.
//

import UIKit

class PromoViewController: UIViewController {
    
    @IBOutlet var promoTextField: UITextField!
    @IBOutlet var doneButton: UIButton!

    @IBAction func doneTap(_ sender: Any) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        promoTextField.placeholder = "promocode".localized
        doneButton.setTitle("done".localized, for: .normal)
    }
    
}
