//
//  SearchResultCellModel.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import RxDataSources

struct SearchTableViewSection {
    var items: [Item]
}

extension SearchTableViewSection: SectionModelType {
    public typealias Item = SearchItem
    
    init(original: SearchTableViewSection, items: [Item]) {
        self = original
        self.items = items
    }
}

/**
# (S) SearchResultCellModel
- Author: Mephrine
- Date: 20.07.12
- Note: 검색 결과 정보를 보여주는 Cell의 Model
*/
struct SearchResultCellModel {
    let model: SearchItem

    init(model: SearchItem) {
        self.model = model
    }
}

