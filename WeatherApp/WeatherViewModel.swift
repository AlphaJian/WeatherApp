//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit

enum InputType {
    case city(String)
    case zipcode(UInt)
    case gps(String, String)
    case inputError
}

class WeatherViewModel {

    private var model: WeatherModel

    init(model: WeatherModel) {
        self.model = model
    }

    func judgeInputType(input: String) -> InputType {
        if input.isNumber, let code = UInt(input) {
            return .zipcode(code)
        } else if input.isAlphabetic {
            return .city(input)
        } else if input.isGPS {
            let arr = input.components(separatedBy: ",")
            return .gps(arr[0], arr[1])
        } else {
            return .inputError
        }
    }

}
