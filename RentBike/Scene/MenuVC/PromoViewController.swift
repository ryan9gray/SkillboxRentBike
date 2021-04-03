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
    @IBOutlet var errorLabel: UILabel!
    
    @IBAction func doneTap(_ sender: Any) {
        errorLabel.text = ""
        guard let text = promoTextField.text else { return }
        if output.promocode(text) {
			
        } else {
            errorLabel.text = "Таково промокода не существует"
        }
    }

    struct Output {
        var promocode: (String) -> Bool
    }
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        promoTextField.placeholder = "promocode".localized
        doneButton.setTitle("done".localized, for: .normal)
    }
    
}
