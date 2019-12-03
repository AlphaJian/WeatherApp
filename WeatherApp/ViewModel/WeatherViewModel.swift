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

let tableName = "WeatherResult"

class WeatherViewModel: NSObject {

    public var inputErrorSignal = PublishSubject<Void>()

    public var weatherSignal = PublishSubject<WeatherModel>()

    private var dbManager: SQLiteManager!

    private var weatherResult: WeatherResult!

    public var resultArr: [WeatherResult] = [WeatherResult]()

    override init() {
        super.init()
        dbManager = SQLiteManager(delegate: self)
        dbManager.loadDB()
    }

    func judgeInputType(input: String?) -> Observable<InputType> {
        guard let input = input, !input.isEmpty else {
            return Observable<InputType>.just(.empty)
        }
        if input.isNumberic, let code = UInt(input) {
            weatherResult = WeatherResult(resultId: UUID().uuidString, result: input)
            return Observable<InputType>.just(.zipcode(code))
        } else if input.isAlphabetic {
            weatherResult = WeatherResult(resultId: UUID().uuidString, result: input)
            return Observable<InputType>.just(.city(input))
        } else if input.isGPS {
            let arr = input.components(separatedBy: ",")
            weatherResult = WeatherResult(resultId: UUID().uuidString, result: input)
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

    func insertResult() {
        let result = dbManager.loadMatch(table: tableName, match: "result like '%\(weatherResult.result ?? "")%'", value: [weatherResult.result ?? ""])
        if result.isEmpty {
            dbManager.insert(table: tableName, data: weatherResult.parseSelfToDic())
        }
    }

    func deleteResult(model: WeatherResult) {
        dbManager.delete(table: tableName, data: model.parseSelfToDic())
    }

    func findResult(input: String) -> Observable<Void> {
        resultArr.removeAll()
        let results = dbManager.loadMatch(table: tableName, match: "result like '%\(input)%'", value: [input])
        resultArr =  results.compactMap { WeatherResult(resultId: $0["resultid"] as! String, result: $0["result"] as? String) }
        return Observable<Void>.just(())
    }
}

extension WeatherViewModel: SQLDelegate {
    var sqlSyntaxs: [String] {
        return []
    }

    var dbPathName: String {
        return "/WeatherResult.db"
    }

    func tablePrimaryKey(table: String) -> String {
        return "resultId"
    }
}
