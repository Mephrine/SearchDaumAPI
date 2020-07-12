//
//  SearchService.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

/**
 # (P) HasSearchService
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 검색 관련 서비스 사용 시 채택해야하는 프로토콜
*/
protocol HasSearchService {
    var searchService: SearchService { get }
}

/**
 # (P) HasSearchService
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 검색 관련 서비스 프로토콜에서 구현되는 항목
*/
protocol SearchServiceProtocol {
    func fetchSearchCafe(_ searchText: String, _ sort: String, _ page: Int) -> Single<SearchResult>
    func fetchSearchBlog(_ searchText: String, _ sort: String, _ page: Int) -> Single<SearchResult>
}

final class SearchService: SearchServiceProtocol {
    private let networking = MNetworking()
    
    /**
     # fetchSearchCafe
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
         - searchText : 검색할 텍스트
         - sort : 정렬 기준
         - page : 불러올 페이지
     - Returns: Single<SearchItem>
     - Note: 네트워크 통신을 통해 카페 검색 정보를 받아옴.
    */
    func fetchSearchCafe(_ searchText: String, _ sort: String, _ page: Int) -> Single<SearchResult> {
        networking.session.cancelAllRequests()
        return networking.rx.request(.searchCafe(query: searchText, sort: sort, page: page))
            .map(to: SearchResult.self)
    }
    
    /**
     # fetchSearchBlog
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
         - searchText : 검색할 텍스트
         - sort : 정렬 기준
         - page : 불러올 페이지
     - Returns: Single<SearchItem>
     - Note: 네트워크 통신을 통해 블로그 검색 정보를 받아옴.
    */
    func fetchSearchBlog(_ searchText: String, _ sort: String, _ page: Int) -> Single<SearchResult> {
        networking.session.cancelAllRequests()
        return networking.rx.request(.searchBlog(query: searchText, sort: sort, page: page))
        .map(to: SearchResult.self)
    }
}

extension SearchService: ReactiveCompatible {}

extension Reactive where Base: SearchService {
    /**
     # searchCafe
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
        - searchText : 검색할 텍스트
        - sort : 정렬 기준
        - page : 불러올 페이지
     - Returns: Observable<SearchItem>
     - Note: 카페 검색 정보를 rx로 접근 가능하도록 확장한 함수.
    */
    func searchCafe(searchText: String, sort: String, page: Int) -> Observable<SearchResult> {
        return base.fetchSearchCafe(searchText, sort, page).asObservable()
    }
    
    /**
     # searchUser
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
         - searchText : 검색할 텍스트
         - sort : 정렬 기준
         - page : 불러올 페이지
     - Returns: Observable<SearchItem>
     - Note: 블로그 검색 정보를 rx로 접근 가능하도록 확장한 함수.
    */
    func searchBlog(searchText: String, sort: String, page: Int) -> Observable<SearchResult> {
        return base.fetchSearchBlog(searchText, sort, page).asObservable()
    }
}



