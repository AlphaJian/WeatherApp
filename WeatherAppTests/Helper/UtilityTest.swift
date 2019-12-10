//
//  UtilityTest.swift
//  WeatherAppTests
//
//  Created by ken.zhang on 2019/12/3.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

@testable import WeatherApp
import XCTest

class UtilityTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHelper() {
        XCTAssertTrue("123123123".isNumberic)
        XCTAssertFalse("12312.3123".isNumberic)

        XCTAssertTrue("london".isAlphabetic)
        XCTAssertTrue("London".isAlphabetic)
        XCTAssertTrue("Hong Kong".isAlphabetic)
        XCTAssertFalse("Hong.Kong".isAlphabetic)
        XCTAssertFalse("Hong,Kong".isAlphabetic)
        XCTAssertFalse("Hong;Kong".isAlphabetic)

        XCTAssertFalse("London1".isAlphabetic)
        XCTAssertFalse("123123".isAlphabetic)

        XCTAssertTrue("123.3".isNumberWithPoint)
        XCTAssertTrue("-123.3".isNumberWithPoint)
        XCTAssertTrue("0".isNumberWithPoint)
        XCTAssertFalse("asd".isNumberWithPoint)


        XCTAssertTrue("123.23,-2324.33".isGPS)
        XCTAssertTrue("0,0".isGPS)
        XCTAssertFalse("123.23;-2324.33".isGPS)
    }

    func testTemperature() {
        var temp: Double = 255.0

        XCTAssertEqual(temp.celsius, -18.15)
        XCTAssertEqual(temp.fahrenheit, -0.67)
        XCTAssertEqual(temp.celsiusStr, "-18.15 ℃")
        XCTAssertEqual(temp.fahrenheitStr, "-0.67 ℉")

        temp = 300
        XCTAssertEqual(temp.celsius, 26.85)
        XCTAssertEqual(temp.fahrenheit, 80.33)
        XCTAssertEqual(temp.celsiusStr, "26.85 ℃")
        XCTAssertEqual(temp.fahrenheitStr, "80.33 ℉")
    }

}
