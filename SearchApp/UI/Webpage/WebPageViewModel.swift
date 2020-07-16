//
//  WebPageViewModel.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/15.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import ReactorKit

final class WebPageViewModel: BaseViewModel, Reactor {
    var initialState = State()
    
    let url: String
    
    init(url: String) {
        self.url = url
    }
    
    /**
     # (E) Action
     - Author: Mephrine
     - Date: 20.07.15
     - Note: ReactorKit에서 ViewController에서 실행될 Action을 모아둔 enum
     */
    enum Action {
        case loadView
    }
    
    /**
     # (E) Mutation
     - Author: Mephrine
     - Date: 20.07.15
     - Note: ReactorKit에서 Action이 들어오면 비즈니스 로직 처리 후 변경 값을 리턴하는 로직을 담당하는 Mutation함수에서 처리할 enum 모음
     */
    enum Mutation {
        case loadView
    }
    
    /**
     # (S) State
     - Author: Mephrine
     - Date: 20.07.15
     - Note: ReactorKit에서 상태값을 관리하는 구조체
     */
    struct State {
        var url: URL?
    }
    
    /**
     # mutate
     - Author: Mephrine
     - Date: 20.07.15
     - Parameters:
     - action: 실행된 action
     - Returns: Observable<Mutation>
     - Note: Action이 들어오면 해당 부분을 타고, Service와의 Side Effect 처리를 함. (API 통신 등.) 그리고 Mutaion으로 반환
     */
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadView:
            return Observable.just(.loadView)
        }
    }
    /**
     # reduce
     - Author: Mephrine
     - Date: 20.07.15
     - Parameters:
     - state: 이전 state
     - mutation: 변경된 mutation
     - Returns: Bool
     - Note: 이전의 상태값과 Mutation을 이용해서 새로운 상태값을 반환
     */
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .loadView:
            newState.url = URL(string: url)
        }
        return newState
    }
    
    func decidePolicyFor(url: URL) -> Bool {
        let strUrl    = url.absoluteString
        
        if url.scheme == "http" || url.scheme == "https" {
            if strUrl.contains("/download") || strUrl.contains("/file/") {
                if strUrl.contains(".jpg") || strUrl.contains(".png") || strUrl.contains(".jpeg") || strUrl.contains(".gif") {
                    return true
                } else if strUrl.contains(".hwp") {
                    Utils.openExternalLink(url: url.absoluteString)
                    return false
                } else {
                    steps.accept(AppStep.goSFSafari(url: url.absoluteString))
                    return false
                }
            } else if strUrl.hasSuffix("#") {
                return false
            } else if url.host == "itunes.apple.com" || url.host == "phobos.apple.com" || url.host == ("itms-appss") || url.host == "apps.apple.com" {
                Utils.openExternalLink(url: url.absoluteString)
                return false
            }
        } else if strUrl == "about:blank" {
            return false
        } else if strUrl.starts(with: "file://") {
            return false
        } else if strUrl.starts(with: "tel:") {
            steps.accept(AppStep.goShowTelNumber(url: url.absoluteString))
            return false
        } else if strUrl.starts(with: "sms:") || strUrl.starts(with: "mailto:") {
            Utils.openExternalLink(url: strUrl)
            return false
        }
        return true
    }
    
    // MARK: Action
    @objc func goBack() {
        steps.accept(AppStep.goBackToSearchDetail)
    }
}
