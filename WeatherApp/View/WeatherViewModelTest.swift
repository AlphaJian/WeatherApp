//
//  WeatherViewModelTest.swift
//  WeatherAppTests
//
//  Created by 张坚 on 2019/12/3.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

@testable import WeatherApp
import XCTest
import RxSwift

class WeatherViewModelTest: XCTestCase {

    var viewModel: WeatherViewModel?
    var disposedBag: DisposeBag! = DisposeBag()
    
    override func setUp() {
        // To use RxTest to test
        viewModel = WeatherViewModel()
        viewModel?.deleteAllResult()
    }
    
    func testUpsertResult() {
        // Test insert
        viewModel?.upsertResult(input: "Hong Kong")
        
        viewModel?.findAllResult()
        XCTAssertEqual(viewModel!.resultArr.count, 1)
        var result = viewModel?.resultArr[0]
        XCTAssertEqual(result?.result, "Hong Kong")
        XCTAssertEqual(result?.count, 1)

        // Test update, result count is still one, but count is updated to two
        viewModel?.upsertResult(input: "Hong Kong")
        viewModel?.findAllResult()
        XCTAssertEqual(viewModel?.resultArr.count, 1)
        result = viewModel?.resultArr[0]
        XCTAssertEqual(result?.result, "Hong Kong")
        XCTAssertEqual(result?.count, 2)
        
        viewModel?.deleteAllResult()
    }
    
    func testDeleteResult() {
        //  Insert and delete, result count is zero
        viewModel?.upsertResult(input: "Hong Kong")
        viewModel?.findAllResult()

        var result = viewModel?.resultArr[0]

        viewModel?.deleteResult(model: result!)
        viewModel?.findAllResult()
        
        XCTAssertEqual(viewModel?.resultArr.count, 0)
        
        //  Insert two model and delete one, result count is one
        viewModel?.upsertResult(input: "Hong Kong")
        viewModel?.upsertResult(input: "London")
        
        viewModel?.findAllResult()
        result = viewModel?.resultArr[0]
        viewModel?.deleteResult(model: result!)
        viewModel?.findAllResult()
        XCTAssertEqual(viewModel?.resultArr.count, 1)
        
        viewModel?.deleteAllResult()
    }
    
    func testFindMostResult() {
        // Most result is the most upsert model
        viewModel?.upsertResult(input: "Hong Kong")

        viewModel?.findMostResult().subscribe(onNext: { (result) in
            XCTAssertEqual(result!.result, "Hong Kong")
            }).disposed(by: disposedBag)
        
        viewModel?.upsertResult(input: "Shanghai")
        viewModel?.upsertResult(input: "Shanghai")
        
        viewModel?.findMostResult().subscribe(onNext: { (result) in
            XCTAssertEqual(result!.result, "Shanghai")
            XCTAssertNotEqual(result!.result, "Hong Kong")
        }).disposed(by: disposedBag)
    }
    
    func testFindAllResults() {
        viewModel?.deleteAllResult()

        //  All result should be listed order by count
        viewModel?.upsertResult(input: "Hong Kong")
        viewModel?.upsertResult(input: "Hong Kong")
        viewModel?.upsertResult(input: "Hong Kong")
        
        viewModel?.upsertResult(input: "Longdon")
        viewModel?.upsertResult(input: "Longdon")

        viewModel?.upsertResult(input: "shanghai")

        viewModel?.findAllResult()
        XCTAssertEqual(viewModel?.resultArr.count, 3)
        let result0 = viewModel?.resultArr[0]
        XCTAssertEqual(result0!.result, "Hong Kong")
        XCTAssertEqual(result0!.count, 3)

        let result1 = viewModel?.resultArr[1]
        XCTAssertEqual(result1!.result, "Longdon")
        XCTAssertEqual(result1!.count, 2)

        let result2 = viewModel?.resultArr[2]
        XCTAssertEqual(result2!.result, "shanghai")
        XCTAssertEqual(result2!.count, 1)
        
        viewModel?.deleteAllResult()
    }
    
    func testFindResultByInput() {
        //  Input h can find "shanghai" and "Hong Kong"
        viewModel?.upsertResult(input: "Hong Kong")
        viewModel?.upsertResult(input: "Longdon")
        viewModel?.upsertResult(input: "shanghai")
        
        _ = viewModel?.findResults(input: "h")
        XCTAssertEqual(viewModel?.filterArr.count, 2)
        XCTAssertEqual(viewModel?.filterArr.contains(where: {$0.result == "shanghai"}), true)
        XCTAssertEqual(viewModel?.filterArr.contains(where: {$0.result == "Hong Kong"}), true)
        
        _ = viewModel?.findResults(input: "shanghai")
        XCTAssertEqual(viewModel?.filterArr.count, 1)
        XCTAssertEqual(viewModel?.filterArr.contains(where: {$0.result == "shanghai"}), true)

        _ = viewModel?.findResults(input: "shang")
        XCTAssertEqual(viewModel?.filterArr.count, 1)
        XCTAssertEqual(viewModel?.filterArr.contains(where: {$0.result == "shanghai"}), true)
        
        viewModel?.deleteAllResult()
    }
    
    func testFindResultBySearchText() {
        //  Input exact value to find result
        viewModel?.upsertResult(input: "Hong Kong")
        viewModel?.upsertResult(input: "Longdon")
        viewModel?.upsertResult(input: "shanghai")
        
        let result = viewModel?.findResult(searchText: "Longdon")
        XCTAssertEqual(result!.result, "Longdon")
        
        viewModel?.deleteAllResult()
    }
    
    

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        disposedBag = nil
    }


}
