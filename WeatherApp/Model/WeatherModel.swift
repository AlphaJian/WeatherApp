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
    var coordinate: Coordinate?
    var mainData: MainData?

    private enum CodingKeys: String, CodingKey {
        case wId = "id"
        case name
        case coordinate = "coord"
        case mainData = "main"
    }
}

struct Coordinate: Codable {
    var latitude: Double?
    var lontitude: Double?

    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case lontitude = "lon"
    }
}

struct MainData: Codable {
    var humidity: Float?
    var pressure: Float?
    var temperature: Double?
    var tempMax: Double?
    var tempMin: Double?

    private enum CodingKeys: String, CodingKey {
        case humidity
        case pressure
        case temperature = "temp"
        case tempMax = "temp_max"
        case tempMin = "temp_min"
    }
}
