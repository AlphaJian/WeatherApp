//
//  WeatherModelTest.swift
//  WeatherAppTests
//
//  Created by ken.zhang on 2019/12/3.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

@testable import WeatherApp
import XCTest

func dataWithJson(_ name: String) -> Data {
    let path = Bundle(for: WeatherAppTests.self).url(forResource: name, withExtension: "json")!
    let data = try! Data(contentsOf: path)
    return data
}

class WeatherModelTest: XCTestCase {

    private var data: Data!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        data = dataWithJson("Weather")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test() {
        if let model = try? JSONDecoder().decode(WeatherModel.self, from: data) {
            XCTAssertEqual(model.wId, 0)
            XCTAssertEqual(model.name!, "Mountain View")
            XCTAssertEqual(model.coordinate?.latitude!, 37.39)
            XCTAssertEqual(model.coordinate?.lontitude!, -122.09)
            XCTAssertEqual(model.mainData?.temperature, 284.12)
            XCTAssertEqual(model.mainData?.tempMax, 285.37)
            XCTAssertEqual(model.mainData?.tempMin, 282.59)
            XCTAssertEqual(model.mainData?.humidity, 100)
            XCTAssertEqual(model.mainData?.pressure, 1021)
        }
    }



}
