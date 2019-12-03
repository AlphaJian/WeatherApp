//
//  WeatherResult.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/12/3.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit

struct WeatherResult {
    var resultId: String
    var result: String?
}

extension WeatherResult {
    func parseSelfToDic() -> [String: Any] {
        return ["resultId": resultId,
                "result": result ?? ""]
    }

    mutating func parseDicToSelf(dic: [String: Any]) {
        if let resultId = dic["resultId"] as? String {
            self.resultId = resultId
        }
        self.result = dic["result"] as? String
    }

}
