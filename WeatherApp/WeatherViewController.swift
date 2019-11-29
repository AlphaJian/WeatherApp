//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit
import SnapKit

class WeatherViewController: UIViewController {

    private lazy var tipLabel: UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = "Please input city name or zip code or GPS"
        return lbl
    }()

    private lazy var searchBar: UITextField = {
        let bar = UITextField(frame: CGRect.zero)
        bar.placeholder = "city name or zip code or GPS"
        bar.backgroundColor = UIColor.gray
        bar.textColor = UIColor.black
        return bar
    }()

    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Search", for: .normal)

        return btn
    }()

    private let padding = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        setupUI()
    }

    func setupUI() {
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.height.equalTo(25)
        }

        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-padding)
            make.top.equalTo(tipLabel.snp.bottom).offset(padding)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }

        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.equalTo(tipLabel)
            make.top.equalTo(tipLabel.snp.bottom).offset(padding)
            make.trailing.equalTo(searchButton.snp.leading).offset(-padding)
            make.height.equalTo(30)
        }
    }

}
