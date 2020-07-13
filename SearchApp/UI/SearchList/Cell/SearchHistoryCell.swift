//
//  SearchHistoryCell.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/13.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import UIKit
import Reusable

/**
# (C) SearchHistoryCell
- Author: Mephrine
- Date: 20.07.12
- Note: 검색 히스토리를 보여주는 Cell
*/
final class SearchHistoryCell: UITableViewCell, Reusable {
    private lazy var historyLabel = UILabel(frame: .zero).then {
        $0.backgroundColor = .clear
        $0.textColor = .black
        $0.font = FontUtils.Font(.Regular, size: 14)
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(self.historyLabel)
        self.historyLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(self.snp.left).offset(20)
            $0.right.equalTo(self.snp.right).offset(-20)
        }
        
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     # configure
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
         - item : 검색 히스토리
     - Returns:
     - Note: 검색 히스토리 String 적용
    */
    func configure(item: String) {
        self.historyLabel.text = item
    }
}

