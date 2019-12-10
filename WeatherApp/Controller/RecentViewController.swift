//
//  RecentViewController.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/12/6.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit

class RecentViewController: BaseViewController {

    private var viewModel: WeatherViewModel!
    
    public var weatherBlock: ((WeatherResult) -> ())?
    
    private lazy var tableview: UITableView = {
        let tb = UITableView(frame: CGRect.zero, style: .plain)
        tb.delegate = self
        tb.dataSource = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

        return tb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Recent Search"
        // Do any additional setup after loading the view.
        viewModel = WeatherViewModel()
        view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension RecentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.resultArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = viewModel.resultArr[indexPath.row].result
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        weatherBlock?(viewModel.resultArr[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = viewModel.resultArr[indexPath.row]
            viewModel.resultArr.remove(at: indexPath.row)
            viewModel.deleteResult(model: model)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.setEditing(false, animated: true)
        }
    }
}
