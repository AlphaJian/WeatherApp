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

    private enum CodingKeys: String, CodingKey {
        case wId = "id"
        case name
    }
}

struct Cloud: Codable {
    var all: Int?
}

struct Coordinate: Codable {
    var latitude: String?
    var lontitude: String?

    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case lontitude = "lon"
    }
}

struct MainData: Codable {
    var humidity: Float?
    var pressure: Float?
    var temperature: String?
    var tempMax: String?
    var tempMin: String?

    private enum CodingKeys: String, CodingKey {
        case humidity
        case pressure
        case temperature = "temp"
        case tempMax = "temp_max"
        case tempMin = "temp_min"
    }
}

struct Weather: Codable {
    var desc: String?

    private enum CodingKeys: String, CodingKey {
        case desc = "description"
    }
}
