//
//  WeatherResultTest.swift
//  WeatherAppTests
//
//  Created by 张坚 on 2019/12/7.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

@testable import WeatherApp
import XCTest

class WeatherResultTest: XCTestCase {

    var weatherResult: WeatherResult?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        weatherResult = WeatherResult(resultId: "id1", result: "Hong Kong", count: 1)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModelToDic() {
        let dic = weatherResult?.parseSelfToDic()
        
        XCTAssertEqual(dic!["resultId"] as! String, "id1")
        XCTAssertEqual(dic!["result"] as! String, "Hong Kong")
        XCTAssertEqual(dic!["count"] as! Int, 1)
    }
    
    func testDicToModel() {
        let dic = ["resultid": "id1", "result": "Hong Kong", "count": 1] as [String : Any]
        
        var model = WeatherResult(resultId: "", result: nil, count: nil)
        model.parseDicToSelf(dic: dic)
        
        XCTAssertEqual(model.resultId, "id1")
        XCTAssertEqual(model.result, "Hong Kong")
        XCTAssertEqual(model.count, 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
