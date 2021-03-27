//
//  RidesViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 26.03.2021.
//

import UIKit

class RidesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var items: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }


    struct Input {
        var getItems: (_ completion: @escaping ([String]) -> Void) -> Void
    }
    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
        input.getItems { [weak self] model in
            guard let self = self else { return }
            self.items = model
        }
    }

    func setupTable() {
        tableView.register(cells: [TitleTableViewCell.self])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.5))
        tableFooterView.backgroundColor = .clear
        tableView.tableFooterView = tableFooterView
    }
    
}

extension RidesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withCell: TitleTableViewCell.self)
        cell.configure(title: items[indexPath.row])
        return cell
    }
}
