//
//  UserDefault+Ext.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/13.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    // 검색 히스토리 내역
    var serachHistory: DefaultsKey<[String]?> { .init("serachHistory") }
}
