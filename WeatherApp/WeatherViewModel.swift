//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit
import RxSwift

enum InputType {
    case city(String)
    case zipcode(UInt)
    case gps(String, String)
    case unkown
}

enum ErrorInfo: Error {
    case inputError
    case parseError(Error)
    case networkError
}

class WeatherViewModel {

    public var inputErrorSignal = PublishSubject<Void>()

    public var weatherSignal = PublishSubject<WeatherModel>()

    func judgeInputType(input: String) -> InputType {
        if input.isNumber, let code = UInt(input) {
            return .zipcode(code)
        } else if input.isAlphabetic {
            return .city(input)
        } else if input.isGPS {
            let arr = input.components(separatedBy: ",")
            return .gps(arr[0], arr[1])
        } else {
            return .unkown
        }
    }

    func reqeustWeatherBy(input: InputType) -> Observable<WeatherModel> {
        switch input {
        case .city(let city):
            return Business.reqeustWeaherByCity(cityName: city).flatMap { [unowned self] (data) -> Observable<WeatherModel> in
                do {
                    let model = try JSONDecoder().decode(WeatherModel.self, from: data)
                    return Observable<WeatherModel>.just(model)
                } catch let err {
                    throw ErrorInfo.parseError(err)
                }
            }
        case .zipcode(let code):
            return Business.reqeustWeaherByZipCode(zipCode: code).flatMap { [unowned self] (data) -> Observable<WeatherModel> in
                do {
                    let model = try JSONDecoder().decode(WeatherModel.self, from: data)
                    return Observable<WeatherModel>.just(model)
                } catch let err {
                    throw ErrorInfo.parseError(err)
                }

            }
        case .gps(let lat, let lon):
            return Business.reqeustWeaherByGPS(lat: lat, lon: lon).flatMap { [unowned self] (data) -> Observable<WeatherModel> in
                do {
                    let model = try JSONDecoder().decode(WeatherModel.self, from: data)
                    return Observable<WeatherModel>.just(model)
                } catch let err {
                    throw ErrorInfo.parseError(err)
                }}
        default:
            throw ErrorInfo.inputError
        }
    }
}
