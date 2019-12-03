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
    case empty
    case unkown
}

enum ErrorInfo: Error {
    case inputError(InputType)
    case parseError(Error)
    case networkError
}

class WeatherViewModel {

    public var inputErrorSignal = PublishSubject<Void>()

    public var weatherSignal = PublishSubject<WeatherModel>()

    func judgeInputType(input: String?) -> Observable<InputType> {
        guard let input = input, !input.isEmpty else {
            return Observable<InputType>.just(.empty)
        }
        if input.isNumber, let code = UInt(input) {
            return Observable<InputType>.just(.zipcode(code))
        } else if input.isAlphabetic {
            return Observable<InputType>.just(.city(input))
        } else if input.isGPS {
            let arr = input.components(separatedBy: ",")
            return Observable<InputType>.just(.gps(arr[0], arr[1]))
        } else {
            return Observable<InputType>.just(.unkown)
        }
    }

    func reqeustWeatherBy(input: InputType) -> Observable<Result<Data, ErrorInfo>> {
        switch input {
        case .city(let city):
            return Business.reqeustWeaherByCity(cityName: city).map { Result.success($0) }
        case .zipcode(let code):
            return Business.reqeustWeaherByZipCode(zipCode: code).map { Result.success($0) }
        case .gps(let lat, let lon):
            return Business.reqeustWeaherByGPS(lat: lat, lon: lon).map { Result.success($0) }
        case .empty:
            return Observable<Result<Data, ErrorInfo>>.just(.failure(.inputError(.empty)))
        default:
            return Observable<Result<Data, ErrorInfo>>.just(.failure(.inputError(.unkown)))
        }
    }

    func parseWeatherByData(result: Result<Data, ErrorInfo>) -> Observable<Result<WeatherModel, ErrorInfo>> {
        switch result {
        case .success(let data):
            do {
                let model = try JSONDecoder().decode(WeatherModel.self, from: data)
                return Observable<Result<WeatherModel, ErrorInfo>>.just(.success(model))
            } catch let err {
                return Observable<Result<WeatherModel, ErrorInfo>>.just(.failure(.parseError(err)))
            }
        case .failure(let err):
            return Observable<Result<WeatherModel, ErrorInfo>>.just(.failure(err))
        }

    }
}
