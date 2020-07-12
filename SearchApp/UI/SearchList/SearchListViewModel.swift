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
# (E) APIError
- Author: Mephrine
- Date: 20.07.12
- Note: API Error 모음
*/
enum APIError: Error {
    case noData
    
    var desc: String? {
        switch self {
        case .noData:
            return "Error : NoData"
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
//        case inputSearch(searchText: String)        // 텍스트 입력
//        case loadMore                               // 20개 더 불러오기
    }
    
    /**
     # (E) Mutation
     - Author: Mephrine
     - Date: 20.07.12
     - Note: ReactorKit에서 Action이 들어오면 비즈니스 로직 처리 후 변경 값을 리턴하는 로직을 담당하는 Mutation함수에서 처리할 enum 모음
     */
    enum Mutation {
//        case searchResult(list: [SearchTableViewSection])
//        case searchText(text: String)
//        case getTotalPage(totalPage: Int)
//        case addUserList(list: [SearchTableViewSection])
    }
    
    /**
     # (S) State
     - Author: Mephrine
     - Date: 20.07.12
     - Note: ReactorKit에서 상태값을 관리하는 구조체
     */
    struct State {
        var page: Int = 1
        var totalPage: Int = PAGE_COUNT
        var resultList: [SearchTableViewSection] = [] // 결과 리스트
        var searchUserName: String = ""
        var noDataText: String = ""
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
//        switch action {
//        case .inputSearch(let searchText):
//            <#code#>
//        case .loadMore:
//            <#code#>
//        }
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
//        switch mutation {
//        case .searchResult(let list):
//            <#code#>
//        case .searchText(let text):
//            <#code#>
//        case .getTotalPage(let totalPage):
//            <#code#>
//        case .addUserList(let list):
//            <#code#>
//        }
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
     # isEmptyCurrentUserList
     - Author: Mephrine
     - Date: 20.06.27
     - Parameters:
     - Returns: Bool
     - Note: 현재 UserList가 비어있는 지에 대해 반환
    */
    func isEmptyCurrentResultList() -> Bool {
        if currentState.resultList.isEmpty || (currentState.resultList.first?.items.isEmpty ?? true) {
            return true
        }
        return false
    }
}
