//
//  FAQViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 10.04.2021.
//

import UIKit

class FAQViewController: UIViewController {

    @IBOutlet var q1: UILabel!
    @IBOutlet var a1: UILabel!
    @IBOutlet var q2: UILabel!
    @IBOutlet var a2: UILabel!
    @IBOutlet var q3: UILabel!
    @IBOutlet var a3: UILabel!
    @IBOutlet var q4: UILabel!
    @IBOutlet var a4: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(q1Toggle))
        q1.addGestureRecognizer(tapGesture1)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(q2Toggle))
        q2.addGestureRecognizer(tapGesture2)
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(q3Toggle))
        q3.addGestureRecognizer(tapGesture3)
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(q4Toggle))
        q4.addGestureRecognizer(tapGesture4)
    }

    @objc func q1Toggle() {
        a1.isHidden.toggle()
    }
    @objc func q2Toggle() {
        a2.isHidden.toggle()
    }
    @objc func q3Toggle() {
        a3.isHidden.toggle()
    }
    @objc func q4Toggle() {
        a4.isHidden.toggle()
    }
}
