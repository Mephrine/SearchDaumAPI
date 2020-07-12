//
//  AppFlow.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow
import RxSwift
import UIKit
import SafariServices

/**
 # (C) AppFlow
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 메인화면 네비게이션 관리 Flow.
*/
class AppFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(false, animated: false)
        return viewController
    }()
    
    private let service: AppService
    
    init(service: AppService) {
        self.service = service
    }
    
    deinit {
        log.d("deinit MainFlow")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .goSearchList:
            return goSearchList()
        default:
            return .none
        }
    }
    
    // 메인화면 띄우기.
    private func goSearchList() -> FlowContributors {
        let viewModel = SearchListViewModel(withService: service)
        let mainVC = SearchListViewController.instantiate(withViewModel: viewModel, storyBoardName: "Main")
        self.rootViewController.setViewControllers([mainVC], animated: false)
        
        return .one(flowContributor: FlowContributor.contribute(withNextPresentable: mainVC, withNextStepper: viewModel))
    }
}

/**
 # (C) AppStepper
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 첫 Flow 실행을 위한 Stepper
*/
class AppStepper: Stepper {
    let steps = PublishRelay<Step>()
    private let appService: AppService
    
    init(withService service: AppService) {
        self.appService = service
    }
    
    var initialStep: Step {
        return AppStep.goSearchList
    }
    
    // FlowCoordinator가 Flow에 기여하기 위해 청취할 준비가 되면 step을 한번 방출하는데 사용되어지는 callback.
    func readyToEmitSteps() {
        
    }
}

