//
//  BaseViewModel.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow

/**
 # (C) BaseVM
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 모든 뷰모델이 상속받는 최상위 부모 클래스
*/
class BaseViewModel: Stepper {
    // 네비게이션 이동 관련
    lazy var steps = PublishRelay<Step>()
}
