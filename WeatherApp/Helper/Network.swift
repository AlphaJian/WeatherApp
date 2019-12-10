//
//  Network.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import Alamofire
import RxSwift
import RxAlamofire

let Appid = "95d190a434083879a6398aafd54d9e73"

enum Services {
    case getWeatherByCity(cityName: String)
    case getWeatherByZipCode(zipCode: UInt)
    case getWeatherByGPS(lat: String, lon: String)

    var baseUrl: String {
        return "http://api.openweathermap.org/data/2.5/"
    }

    var requestMeta: (method: Alamofire.HTTPMethod, path: String) {
        switch self {
        case .getWeatherByCity(let cityName):
            return (.get, "/weather?q=\(cityName)&APPID=\(Appid)")
        case .getWeatherByZipCode(let zipCode):
            return (.get, "/weather?zip=\(zipCode)&APPID=\(Appid)")
        case .getWeatherByGPS(let lat, let lon):
            return (.get, "/weather?lat=\(lat)&lon=\(lon)&APPID=\(Appid)")
        }
    }

    func data() -> Observable<Data> {
        let url = URL(string: baseUrl + requestMeta.path)
        return requestData(requestMeta.method, url!).flatMap { (response) -> Observable<Data> in
            return Observable.just(response.1)
        }
    }
}

class Business {
    static func reqeustWeaherByCity(cityName: String) -> Observable<Data> {
        return Services.getWeatherByCity(cityName: cityName).data()
    }

    static func reqeustWeaherByZipCode(zipCode: UInt) -> Observable<Data> {
        return Services.getWeatherByZipCode(zipCode: zipCode).data()
    }

    static func reqeustWeaherByGPS(lat: String, lon: String) -> Observable<Data> {
        return Services.getWeatherByGPS(lat: lat, lon: lon).data()
    }
}
