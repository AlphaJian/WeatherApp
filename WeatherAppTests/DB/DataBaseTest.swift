//
//  DataBaseTest.swift
//  WeatherAppTests
//
//  Created by 张坚 on 2019/12/7.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

@testable import WeatherApp
import XCTest

class DataBaseTest: XCTestCase {
    
    private var dbManager: SQLiteManager!

    private let tableName = "WeatherResult"
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dbManager = SQLiteManager(delegate: self)
        dbManager.loadDB()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        clearTestData()
        dbManager.closeDB()
    }

    func testDBExists() {
        XCTAssertTrue(dbManager.checkTable(table: tableName))
        XCTAssertFalse(dbManager.checkTable(table: "OtherTableName"))
    }
    
    func testInsertData() {
        let model = WeatherResult(resultId: "1", result: "London", count: 1)
        insertData(data: model.parseSelfToDic())
        XCTAssertEqual(countResults(), 1)

        let results = queryDataAll()
        let loadData = results[0]
        XCTAssertEqual(loadData["resultid"] as! String, "1")
        XCTAssertEqual(loadData["result"] as! String, "London")
        XCTAssertEqual(loadData["count"] as! Int, 1)
        
        clearTestData()
    }
    
    func testUpdateData() {
        var model = WeatherResult(resultId: "1", result: "London", count: 1)
        insertData(data: model.parseSelfToDic())
        XCTAssertEqual(countResults(), 1)

        //  modify model's result
        model.result = "Hong Kong"
        updateData(data: model.parseSelfToDic())
        XCTAssertEqual(countResults(), 1)

        let results = queryDataAll()
        let loadData = results[0]
        
        XCTAssertEqual(loadData["resultid"] as! String, "1")
        XCTAssertEqual(loadData["result"] as! String, "Hong Kong")
        XCTAssertEqual(loadData["count"] as! Int, 1)
        
        clearTestData()
    }
    
    func testDeleteData() {
        let model = WeatherResult(resultId: "1", result: "London", count: 1)
        insertData(data: model.parseSelfToDic())
        XCTAssertEqual(countResults(), 1)
        
        deleteData(data: model.parseSelfToDic())
        XCTAssertEqual(countResults(), 0)
        
        clearTestData()
    }
    
    func queryDataAll() -> [[String: Any]] {
        return dbManager.loadMatch(table: tableName, match: "1==1", value: [])
    }
    
    func updateData(data: [String: Any]) {
        dbManager.update(table: tableName, data: data)
    }
    
    func insertData(data: [String: Any]) {
        dbManager.insert(table: tableName, data: data)
    }
    
    func deleteData(data: [String: Any]) {
        dbManager.delete(table: tableName, data: data)
    }
    
    func countResults() -> Int {
        return dbManager.loadAll(table: tableName).count
    }
    
    func clearTestData() {
        dbManager.deleteAll(table: tableName)
    }

}

extension DataBaseTest: SQLDelegate {
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
