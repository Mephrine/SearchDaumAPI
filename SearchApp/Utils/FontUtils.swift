//
//  FontUtils.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import UIKit

class FontUtils {
    /**
     # (E) FONT_TYPE
     - Author: Mephrine
     - Date: 20.07.12
     - Note: 사용하는 폰트를 모아둔 enum
     */
    enum FONT_TYPE: String {
        case Medium = "AppleSDGothicNeo-Medium"
        case Regular = "AppleSDGothicNeo-Regular"
        case Bold = "AppleSDGothicNeo-Bold"
        case SemiBold = "AppleSDGothicNeo-SemiBold"
    }
    
    /**
     # Font
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
        - type: 적용할 폰트 타입
        - size: 폰트 사이즈
     - Returns:
     - Note: 적용할 폰트 타입을 받아서 UIFont로 전환해주는 함수.
     */
    static func Font(_ type: FONT_TYPE, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size)!
    }
}
