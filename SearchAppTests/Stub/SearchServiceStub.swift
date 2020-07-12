//
//  SearchServiceStub.swift
//  SearchAppTests
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import RxSwift
@testable import SearchApp

struct SearchServiceStub: SearchServiceProtocol {
    func fetchSearchCafe(_ searchText: String, _ sort: SearchSort, _ page: Int) -> Single<SearchResult> {
        return Single<SearchResult>.create { observer in
            if let dummy = SearchCafeDummy.jsonData {
                observer(.success(dummy))
            } else {
                observer(.error(APIError.noData))
            }
            return Disposables.create()
        }
    }
    
    func fetchSearchBlog(_ searchText: String, _ sort: SearchSort, _ page: Int) -> Single<SearchResult> {
        return Single<SearchResult>.create { observer in
            if let dummy = SearchBlogDummy.jsonData {
                observer(.success(dummy))
            } else {
                observer(.error(APIError.noData))
            }
            return Disposables.create()
        }
    }
}

