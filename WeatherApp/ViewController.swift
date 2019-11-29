//
//  ViewController.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit
import RxAlamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=shanghai&APPID=95d190a434083879a6398aafd54d9e73")
        requestJSON(.get, url!).subscribe(onNext: { (response, data) in
            print(data)
            })
    }


}

