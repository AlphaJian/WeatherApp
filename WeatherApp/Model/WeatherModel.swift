//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit

struct WeatherModel: Codable {
    var wId: UInt
    var name: String?
    var zipCode: String?
    var searchedLat: String?
    var searchedLon: String?
    var coordinate: Coordinate?
    var mainData: MainData?

    private enum CodingKeys: String, CodingKey {
        case wId = "id"
        case name
        case coordinate = "coord"
        case mainData = "main"
        case zipCode
        case searchedLat
        case searchedLon
    }
}

struct Coordinate: Codable {
    var latitude: Float?
    var lontitude: Float?

    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case lontitude = "lon"
    }
}

struct MainData: Codable {
    var humidity: Float?
    var pressure: Float?
    var temperature: Float?
    var tempMax: Float?
    var tempMin: Float?

    private enum CodingKeys: String, CodingKey {
        case humidity
        case pressure
        case temperature = "temp"
        case tempMax = "temp_max"
        case tempMin = "temp_min"
    }
}
