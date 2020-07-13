//
//  SearchResultCell.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Kingfisher
import Reusable
import UIKit

/**
# (C) SearchResultCell
- Author: Mephrine
- Date: 20.07.12
- Note: 검색 결과를 보여주는 Cell
*/
final class SearchResultCell: UITableViewCell, NibReusable {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    /**
     # configure
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
         - item : Cell Model
     - Returns:
     - Note: Cell Model 정보를 Cell에 구성
    */
    func configure(model: SearchResultCellModel) {
        
    }
}

