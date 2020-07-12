//
//  AppStep.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import ReactorKit
import RxFlow

/**
 # AppStep
 - Author: Mephrine
 - Date: 20.07.12
 - Parameters:
 - Returns:
 - Note: 앱 네비게이션 이동 관련 모음 enum.
*/
enum AppStep: Step {
    // MARK: - Init
    case goSearchList                                    // 검색 리스트 화면으로 이동
    
    // MARK: - Search List
    case goSearchDetail(info: SearchResult, row: Int)    // 검색 상세 화면으로 이동
    
    // MARK: - Search Detail
    case goBackToMain(row: Int?)                         // 검색 리스트 화면으로 되돌아가기
    case goWebpage(url: String, title: String)           // 웹페이지 화면으로 이동
    
    // MARK: - Webpage
    case goBackToSearchDetail                            // 검색 상세 화면으로 되돌아가기
}
