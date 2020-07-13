//
//  SearchListViewModel.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import ReactorKit


/**
# (E) SearchFilter
- Author: Mephrine
- Date: 20.07.12
- Note: SearchFilter 모음
*/
enum SearchFilter: String {
    case all = "All"
    case blog = "Blog"
    case cafe = "Cafe"
    
    var desc: String {
        switch self {
        case .all:
            return "All"
        case .blog:
            return "Blog"
        case .cafe:
            return "Cafe"
        }
    }
    
    var index: Int {
        switch self {
        case .all:
            return 0
        case .blog:
            return 1
        case .cafe:
            return 2
        }
    }
}

/**
 # (E) SearchSort
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 검색 정렬 방식
*/
enum SearchSort: String {
    case accuracy = "Datetime"
    case recency = "Title"
    
    var value: String {
        switch self {
        case .recency:
            return "recency"
        default:
            return "accuracy"
        }
    }
}

/**
 # (C) SearchListViewModel
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 메인화면 ViewModel
 */
final class SearchListViewModel: BaseViewModel, Reactor {
    var initialState = State()
    
    // Service
    typealias Services = HasSearchService
    var service: Services
    
    // e.g.
    var isLoading = PublishSubject<Bool>()         // 로딩바 관리
    var isSearchReload = PublishSubject<Bool>()    // 검색어 변경으로 인한 리로드
    
    init(withService service: AppService) {
        self.service = service
    }
    
    /**
     # (E) Action
     - Author: Mephrine
     - Date: 20.07.12
     - Note: ReactorKit에서 ViewController에서 실행될 Action을 모아둔 enum
     */
    enum Action {
        case focusSearchBar(isFocusing: Bool)           // 검색바 포커스
        case tapHistory(selected: String)               // 예전 검색 기록 클릭
        case tapSearchButton(searchText: String)        // 검색 버튼 클릭
        case loadMore                                   // 다음 페이지 불러오기
        case tapFilterButton                            // 필터뷰 버튼 클릭
        case selectFilter(selected: String?)            // 변경할 필터 선택
        case selectSort(selected: String?)              // 변경할 정렬 시트 선택
    }
    
    /**
     # (E) Mutation
     - Author: Mephrine
     - Date: 20.07.12
     - Note: ReactorKit에서 Action이 들어오면 비즈니스 로직 처리 후 변경 값을 리턴하는 로직을 담당하는 Mutation함수에서 처리할 enum 모음
     */
    enum Mutation {
        case historyList(list: [String])
        case searchResult(list: [SearchItem])
        case searchText(text: String)
        case totalPage(totalPage: Int)
        case isEndPage(isEnd: Bool)
        case addResultList(list: [SearchItem])
        case showFilterView(isShowing: Bool)
        case changeFilter(selected: SearchFilter)
        case changeSort(selected: SearchSort)
    }
    
    /**
     # (S) State
     - Author: Mephrine
     - Date: 20.07.12
     - Note: ReactorKit에서 상태값을 관리하는 구조체
     */
    struct State {
        var page: Int = 1                               // 페이지 관리
        var totalPage: Int = PAGE_COUNT                 // 불러온 총 페이지 수
        var isEnd: Bool = false                         // 페이징 가능 여부
        var resultList: [SearchTableViewSection] = []   // 실제 테이블뷰에 보여질 리스트
        var allList: [SearchItem] = []                  // 모든 리스트
        var searchText: String = ""                     // 검색한 텍스트
        var noDataText: String = ""                     // No Data or No Input
        var historyList: [String] = []                  // 히스토리 리스트
        var isShowingFilterView: Bool = false           // 필터뷰 숨김 여부
        var filterState: SearchFilter = .all            // 필터 상태값
        var sortState: SearchSort = .accuracy           // 정렬 상태값
    }
    
    /**
     # mutate
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
     - action: 실행된 action
     - Returns: Observable<Mutation>
     - Note: Action이 들어오면 해당 부분을 타고, Service와의 Side Effect 처리를 함. (API 통신 등.) 그리고 Mutaion으로 반환
     */
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // 히스토리 뷰 숨김 여부
        case .focusSearchBar(let isFocusing):
            if !isFocusing {
                return Observable.just(Mutation.historyList(list: []) )
            }
            return service.searchService.rx.searchHistory()
                .map { Mutation.historyList(list: $0 ?? []) }
        // 히스토리 내역 중 선택된 텍스트로 검색
        case .tapHistory(let selected):
            let requestList = requestSearchObservable(searchText: selected, sort: currentState.sortState, filter: currentState.filterState, page: 1)
                .share(replay: 1, scope: .forever)
            
            let pageCntObservable = requestList.map { $0.totalCount }
                .filterNil()
                .map { Mutation.totalPage(totalPage: $0) }
            
            let isEndPageObservable = requestList.map { $0.isEnd }
                .filterNil()
                .map { Mutation.isEndPage(isEnd: $0) }
            
            let requestObservable = requestList.map{ $0.items }
                .filterNil()
                .map{ Mutation.searchResult(list: $0) }
            
            return .concat(requestObservable, pageCntObservable, isEndPageObservable)
        // 검색어로 검색하기
        case .tapSearchButton(let searchText):
            let requestList = requestSearchObservable(searchText: searchText, sort: currentState.sortState, filter: currentState.filterState, page: 1)
                .share(replay: 1, scope: .forever)
            
            let pageCntObservable = requestList.map { $0.totalCount }
                .filterNil()
                .map { Mutation.totalPage(totalPage: $0) }
                
            let isEndPageObservable = requestList.map { $0.isEnd }
                .filterNil()
                .map { Mutation.isEndPage(isEnd: $0) }
            
            let requestObservable = requestList.map{ $0.items }
                .filterNil()
                .map{ Mutation.searchResult(list: $0) }
            
            return .concat(requestObservable, pageCntObservable, isEndPageObservable)
        // 더 불러오기
        case .loadMore:
            self.isLoading.onNext(true)
            
            return requestSearchObservable(searchText: currentState.searchText, sort: currentState.sortState, filter: currentState.filterState, page: currentState.page)
                .map{ $0.items }
                .filterNil()
                .map{ Mutation.searchResult(list: $0) }
        // 필터뷰 보이기
        case .tapFilterButton:
            return Observable.just(.showFilterView(isShowing: true))
        // 선택한 필터로 리로드
        case .selectFilter(let selected):
            let selectedFilter = SearchFilter.init(rawValue: selected ?? "All")!
            
            let requestList = requestSearchObservable(searchText: currentState.searchText, sort: currentState.sortState, filter: selectedFilter, page: 1)
                .share(replay: 1, scope: .forever)
            
            let pageCntObservable = requestList.map { $0.totalCount }
                .filterNil()
                .map { Mutation.totalPage(totalPage: $0) }
            
            let isEndPageObservable = requestList.map { $0.isEnd }
                .filterNil()
                .map { Mutation.isEndPage(isEnd: $0) }
            
            let requestObservable = requestList.map{ $0.items }
                .filterNil()
                .map{ Mutation.searchResult(list: $0) }
            
            let filterObservable = Observable.just(Mutation.changeFilter(selected: selectedFilter))
            
            return .concat(filterObservable, requestObservable, pageCntObservable, isEndPageObservable)
        // 선택한 정렬로 리로드
        case .selectSort(let selected):
            let selectedSort = SearchSort.init(rawValue: selected ?? "Datetime")!
            
            let requestList = requestSearchObservable(searchText: currentState.searchText, sort: selectedSort, filter: currentState.filterState, page: 1)
                .share(replay: 1, scope: .forever)
            
            let pageCntObservable = requestList.map { $0.totalCount }
                .filterNil()
                .map { Mutation.totalPage(totalPage: $0) }
            
            let isEndPageObservable = requestList.map { $0.isEnd }
                .filterNil()
                .map { Mutation.isEndPage(isEnd: $0) }
            
            let requestObservable = requestList.map{ $0.items }
                .filterNil()
                .map{ Mutation.searchResult(list: $0) }
            
            let sortObservable = Observable.just(Mutation.changeSort(selected: selectedSort))
            return .concat(sortObservable, requestObservable, pageCntObservable, isEndPageObservable)
        }
    }
    /**
     # reduce
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
     - state: 이전 state
     - mutation: 변경된 mutation
     - Returns: Bool
     - Note: 이전의 상태값과 Mutation을 이용해서 새로운 상태값을 반환
     */
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        // 히스토리뷰 보이기
        case .historyList(let list):
            newState.historyList = list
        // 검색 결과 리스트
        case .searchResult(let list):
            newState.page = 2
            if list.isEmpty {
                // 초기화 및 NoDataView 노출
                newState.allList = [SearchItem]()
                newState.resultList = [SearchTableViewSection]()
                newState.noDataText = STR_SEARCH_NO_DATA
            } else {
                newState.noDataText = ""
                 // 페이징 시, 분할정렬하기위해 미리 정렬해두기
                let sortedList: [SearchItem]
                if state.sortState == .accuracy {
                    sortedList = list.sorted(by: { sortText(str1: $0.name!, str2: $1.name!) })
                } else {
                    sortedList = list.sorted(by: { sortDateTime(str1: $0.datetime!, str2: $1.datetime!) })
                }
                newState.allList = sortedList
                newState.resultList = [SearchTableViewSection(items: sortedList)]
            }
            
        // 검색한 텍스트
        case .searchText(let text):
            newState.searchText = text
        // 검색한 페이지 수
        case .totalPage(let totalPage):
            newState.totalPage = totalPage
        // 페이징 가능 여부
        case .isEndPage(let isEnd):
            newState.isEnd = isEnd
        // 더 불러온 데이터
        case .addResultList(let list):
            self.isLoading.onNext(false)
            let sortedList: [SearchItem]
            // 분할정렬로 재정렬.
            if state.sortState == .accuracy {
                sortedList = divideSortText(list: list)
            } else {
                sortedList = divideSortDateTime(list: list)
            }
            newState.allList.append(contentsOf: sortedList)
            let minCnt = min(currentState.page * PAGE_COUNT, newState.allList.count) - 1
            newState.resultList = [SearchTableViewSection(items: Array(sortedList[0..<minCnt]))]
            newState.page += 1
            
        // 필터뷰 보이기
        case .showFilterView(let isShowing):
            newState.isShowingFilterView = isShowing
        // 필터 상태 변경
        case .changeFilter(let selected):
            newState.filterState = selected
        // 정렬 상태 변경
        case .changeSort(let selected):
            newState.sortState = selected
        }
        return newState
    }
    
    //MARK: -e.g.
    /**
     # chkEnablePaging
     - Author: Mephrine
     - Date: 20.06.27
     - Parameters:
     - Returns: Bool
     - Note: 페이징이 가능한 지에 대한 여부 반환
    */
    func chkEnablePaging() -> Bool {
        if (currentState.page - 1) * PAGE_COUNT < currentState.totalPage {
            return true
        }
        return false
    }
    
    /**
     # isEmptyCurrentResultList
     - Author: Mephrine
     - Date: 20.06.27
     - Parameters:
     - Returns: Bool
     - Note: 현재 List가 비어있는 지에 대해 반환
    */
    func isEmptyCurrentResultList() -> Bool {
        if currentState.allList.isEmpty {
            return true
        }
        return false
    }
    
    /**
     # requestSearchObservable
     - Author: Mephrine
     - Date: 20.07.13
     - Parameters:
        -searchText : 검색어
        -sort : 정렬명
        -filter : 필터명
        -page : 페이지 수
     - Returns: Observable<[SearchItem]>
     - Note: 필터별 다른 API를 태운 후 Observable을 반환
    */
    func requestSearchObservable(searchText: String, sort: SearchSort, filter: SearchFilter, page: Int) -> Observable<SearchResult> {
        if filter == .all {
            // 25 / 25개씩 불러와서 정렬하고 25개만 끊어서 보여주기.
            return service.searchService.rx.searchAll(searchText: searchText, sort: sort, page: page).asObservable()
        }
        else if filter == .cafe {
            return service.searchService.rx.searchCafe(searchText: searchText, sort: sort, page: page).asObservable()
        }
        else {
            return service.searchService.rx.searchBlog(searchText: searchText, sort: sort, page: page).asObservable()
        }
    }
    
    
    /**
     # sortText
     - Author: Mephrine
     - Date: 20.07.13
     - Parameters:
        -str1 : 정렬 String1
        -str2 : 정렬 String2
     - Returns: Bool
     - Note: sorted 고차함수를 통한 텍스트 순으로 정렬을 위한 함수
    */
    func sortText(str1: String, str2: String) -> Bool {
        var compared: Bool = false
        //두 문자열 비교전 2개 중에 작은 길이가 기준 길이
        let limit = min(str1.count, str2.count)
        let arr1: [Character] = str1.map { $0 }
        let arr2: [Character] = str2.map { $0 }
        for idx in 0 ..< limit {
            if arr1[idx] == arr2[idx] {
                continue
            } else {
                compared = arr1[idx] > arr2[idx]
                break
            }
        }
        return compared
    }
    
    /**
     # sortDateTime
     - Author: Mephrine
     - Date: 20.07.13
     - Parameters:
        -str1 : 정렬 String1
        -str2 : 정렬 String2
     - Returns: Bool
     - Note: sorted 고차함수를 통한 날짜 순으로 정렬을 위한 함수
     */
    func sortDateTime(str1: String, str2: String) -> Bool {
        var compared: Bool = false
        //두 문자열 비교전 2개 중에 작은 길이가 기준 길이
        let limit = min(str1.count, str2.count)
        let arr1: [Character] = str1.map { $0 }
        let arr2: [Character] = str2.map { $0 }
        for idx in 0 ..< limit {
            if arr1[idx] == arr2[idx] {
                continue
            } else {
                compared = arr1[idx] > arr2[idx]
                break
            }
        }
        return compared
    }
    
    /**
    # divideSortText
    - Author: Mephrine
    - Date: 20.07.13
    - Parameters:
       -list : 분할정렬할 list
    - Returns: [SearchItem]
    - Note: allList와 분할정렬해서 반환
    */
    func divideSortText(list: [SearchItem]) -> [SearchItem] {
        let sortedList = list.sorted(by: { sortText(str1: $0.name!, str2: $1.name!) })
        
        var index1: Int = 0
        var index2: Int = 0
        var sortedAllList = [SearchItem]()
        while index1 < sortedList.count - 1 && index2 < currentState.allList.count - 1 {
            if sortText(str1: sortedList[index1].name!, str2: currentState.allList[index2].name!) {
                index1 += 1
                sortedAllList.append(sortedList[index1])
            } else {
                index2 += 1
                sortedAllList.append(currentState.allList[index2])
            }
        }
        
        // 남은 반대쪽 데이터 append
        if index1 < sortedList.count - 1 {
            for i in index1 ..< sortedList.count - 1 {
                sortedAllList.append(sortedList[i])
            }
        }
        
        if index2 < currentState.allList.count - 1 {
            for i in index2 ..< currentState.allList.count - 1 {
                sortedAllList.append(currentState.allList[i])
            }
        }
        
        return sortedAllList
    }
    
    /**
    # divideSortDateTime
    - Author: Mephrine
    - Date: 20.07.13
    - Parameters:
       -list : 분할정렬할 list
    - Returns: [SearchItem]
    - Note: allList와 분할정렬해서 반환
    */
    func divideSortDateTime(list: [SearchItem]) -> [SearchItem] {
        let sortedList = list.sorted(by: { sortDateTime(str1: $0.datetime!, str2: $1.datetime!) })
        
        var index1: Int = 0
        var index2: Int = 0
        var sortedAllList = [SearchItem]()
        while index1 < sortedList.count - 1 && index2 < currentState.allList.count - 1 {
            if sortDateTime(str1: sortedList[index1].datetime!, str2: currentState.allList[index2].datetime!) {
                index1 += 1
                sortedAllList.append(sortedList[index1])
            } else {
                index2 += 1
                sortedAllList.append(currentState.allList[index2])
            }
        }
        
        // 남은 반대쪽 데이터 append
        if index1 < sortedList.count - 1 {
            for i in index1 ..< sortedList.count - 1 {
                sortedAllList.append(sortedList[i])
            }
        }
        
        if index2 < currentState.allList.count - 1 {
            for i in index2 ..< currentState.allList.count - 1 {
                sortedAllList.append(currentState.allList[i])
            }
        }
        
        return sortedAllList
    }
}
