//
//  Utils.swift
//  SearchAppTests
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import SwiftyJSON

func jsonStringToData<T>(_ jsonString: String) -> T? {
    if let data = jsonString.data(using: .utf8) {
        do {
            let json = try JSON(data: data)
            
            let returnData = json.to(type: T.self) as? T
            return returnData
        } catch {}
    }
    return nil
}
