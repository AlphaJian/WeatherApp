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

    private var weatherSearch: String?

    public var resultArr: [WeatherResult] = [WeatherResult]()
    public var filterArr: [WeatherResult] = [WeatherResult]()

    public var returnBlock: ((String) -> ())?
    
    override init() {
        super.init()
        dbManager = SQLiteManager(delegate: self)
        dbManager.loadDB()
        findAllResult()
    }

    func judgeInputType(input: String?) -> Observable<InputType> {
        guard let input = input, !input.isEmpty else {
            return Observable<InputType>.just(.empty)
        }
        if input.isNumberic, let code = UInt(input) {
            weatherSearch = input
            return Observable<InputType>.just(.zipcode(code))
        } else if input.isAlphabetic {
            weatherSearch = input
            return Observable<InputType>.just(.city(input))
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

    func upsertResult(input: String) {
        if var model = findResult(searchText: input), let count = model.count {
            model.count = count + 1
            updateResult(model: model)
        } else {
            dbManager.insert(table: tableName, data: WeatherResult(resultId: UUID().uuidString, result: input, count: 1).parseSelfToDic())
        }
    }

    func updateResult(model: WeatherResult) {
        dbManager.update(table: tableName, data: model.parseSelfToDic())
    }

    func deleteResult(model: WeatherResult) {
        dbManager.delete(table: tableName, data: model.parseSelfToDic())
    }

    func findResult(searchText: String) -> WeatherResult? {
        let results = dbManager.loadMatch(table: tableName, match: "result == '\(searchText)'", value: [searchText])
        var model = WeatherResult(resultId: "", result: nil, count: nil)
        if !results.isEmpty {
            model.parseDicToSelf(dic: results[0])
            return model
        } else {
            return nil
        }
    }

    func findResults(input: String) -> Observable<Void> {
        filterArr.removeAll()
        let results = dbManager.loadMatch(table: tableName, match: "result like '%\(input)%'", value: [input])
        filterArr = results.compactMap { WeatherResult(resultId: $0["resultid"] as! String, result: $0["result"] as? String, count: $0["count"] as? Int) }
        return Observable<Void>.just(())
    }

    func findAllResult() {
        resultArr.removeAll()
        let results = dbManager.loadMatch(table: tableName, match: "result like '%%'", value: [""])
        resultArr =  results.compactMap { WeatherResult(resultId: $0["resultid"] as! String, result: $0["result"] as? String, count: $0["count"] as? Int) }
    }

    func findMostResult() -> Observable<WeatherResult?> {
        let results = dbManager.loadMatch(table: tableName, match: " 1=1 order by count desc", value: [])
        if results.isEmpty {
            return Observable<WeatherResult?>.just(nil)
        } else {
            return Observable<WeatherResult?>.just(WeatherResult(resultId: results[0]["resultid"] as! String, result: results[0]["result"] as? String, count: results[0]["count"] as? Int) )
        }
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
