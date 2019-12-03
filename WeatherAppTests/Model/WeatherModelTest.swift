//
//  WeatherModelTest.swift
//  WeatherAppTests
//
//  Created by ken.zhang on 2019/12/3.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

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
        
    }



}
