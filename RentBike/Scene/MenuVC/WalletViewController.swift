//
//  WalletViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 26.03.2021.
//

import UIKit

class WalletViewController: UIViewController {
    @IBOutlet var promoTextField: UITextField!
    @IBOutlet var doneButton: UIButton!

    @IBAction func doneTap(_ sender: Any) {
        alert()
        promoTextField.text = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func alert() {
        let alert = UIAlertController(
            title: nil,
            message: "Заявление получено, менеджер вышлет вам счет в течение 24 часов”",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
