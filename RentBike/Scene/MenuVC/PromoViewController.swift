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
        output.promocode(text, { [weak self] bool in
            self?.errorLabel.text = bool ? "" : "Таково промокода не существует"
        })
    }

    struct Output {
        var promocode: ((String, _ completion: @escaping (Bool) -> Void) -> ())
    }
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        promoTextField.placeholder = "promocode".localized
        doneButton.setTitle("done".localized, for: .normal)
    }
    
}
