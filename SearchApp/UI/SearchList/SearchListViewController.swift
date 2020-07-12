//
//  SearchListViewController.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import ReactorKit
import Reusable
import RxOptional
import RxSwift
import RxDataSources
import RxAnimated
import SnapKit
import Then
import UIKit

/**
 # (C) SearchListViewController
 - Author: Mephrine
 - Date: 20.07.12
 - Note: 메인화면 ViewController
 */
final class SearchListViewController: BaseViewController, StoryboardView, StoryboardBased {
    //MARK : - Variable
    let ANIMATION_DURATION = 0.3
    
    // TableView DataSource
    typealias MainDataSource = RxTableViewSectionedReloadDataSource<SearchTableViewSection>
    private var dataSource: MainDataSource {
        return .init(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell: SearchResultCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(item: item)
            
            return cell
        })
    }
    
    //MARK: - View
    private lazy var searchBar = UISearchBar(frame: .zero).then {
        $0.placeholder = STR_SEARCH_PLACE_HOLDER
        $0.searchBarStyle = .prominent
        $0.sizeToFit()
        $0.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            $0.setShowsScope(true, animated: true)
        }
    }
    
    private lazy var searchTableView = UITableView(frame: .zero, style: .plain).then {
        $0.register(cellType: SearchResultCell.self)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.rowHeight = 90
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.keyboardDismissMode = .onDrag
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
    
    private lazy var noDataView = UIView(frame: .zero).then {
        $0.backgroundColor = .white
    }
    
    private lazy var noDataLabel = UILabel(frame: .zero).then {
        $0.backgroundColor = .clear
        $0.textColor = .black
        $0.text = STR_SEARCH_NO_INPUT
        $0.font = FontUtils.Font(.Bold, size: 24)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private lazy var loadingView =  UIActivityIndicatorView(style: .gray).then {
        $0.frame = CGRect(x: 0, y: 0, width: self.searchTableView.bounds.width, height: 44)
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Async.main(after: ANIMATION_DURATION * 2) { [weak self] in
            self?.searchBar.becomeFirstResponder()
        }
        
    }
    
    //MARK: - Bind
    func bind(reactor: SearchListViewModel) {
        
        // action
        // searchBar에 텍스트 변경 옵션이 일어날 경우
        self.searchBar.rx.text
            .map{ $0?.trimSide }
            .asDriver(onErrorJustReturn: "")
            .debounce(RxTimeInterval.milliseconds(500))
            .distinctUntilChanged()
            .map{ Reactor.Action.inputSearch(searchText: $0 ?? "") }
            .drive(reactor.action)
            .disposed(by: disposeBag)
        
        //state
        // TableView
        reactor.state
            .map{ $0.resultList }
            .bind(to: self.searchTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // 데이터가 없거나 SearchBar 검색어가 비어있는 경우
        reactor.state.map{ $0.noDataText }
            .distinctUntilChanged()
            .observeOn(Schedulers.main)
            .subscribe(onNext: { [weak self] in
                self?.noDataView.rx.animated.fade(duration: self?.ANIMATION_DURATION ?? 0.3).isHidden.onNext($0.isEmpty)
                self?.noDataLabel.rx.animated.fade(duration: self?.ANIMATION_DURATION ?? 0.3).text.onNext($0)
            })
            .disposed(by: disposeBag)
        
        // 재검색 시, 스크롤 상단으로 올리기
        reactor.isSearchReload
            .filter{ $0 == true }
            .filter{ _ in !reactor.isEmptyCurrentResultList() }
            .observeOn(Schedulers.main)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }).disposed(by: disposeBag)
        
        // 로딩바 관리
        reactor.isLoading
            .distinctUntilChanged()
            .observeOn(Schedulers.main)
            .subscribe(onNext:{ [weak self] in
                guard let self = self else { return }
                if $0 {
                    self.loadingView.isHidden = false
                    self.loadingView.startAnimating()
                    self.searchTableView.tableFooterView = self.loadingView
                } else {
                    self.loadingView.stopAnimating()
                    self.searchTableView.tableFooterView = nil
                    self.loadingView.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        // e.g.
        // 마지막 Section의 마지막 Row가 보여질 경우 다음 페이지 데이터 불러오기
        self.searchTableView.rx.willDisplayCell
            .filter{ _ in reactor.chkEnablePaging() }
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self else { return }
                let lastSectionIndex = self.searchTableView.numberOfSections - 1
                let lastRowIndex = self.searchTableView.numberOfRows(inSection: lastSectionIndex) - 1
                if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                    self.reactor?.action.onNext(.loadMore)
                }
            }).disposed(by: disposeBag)
    }
    
    //MARK: - UI
    override func initView() {
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.searchTableView)
        self.view.addSubview(self.noDataView)
        self.noDataView.addSubview(self.noDataLabel)
        
        self.constraints()
    }
    
    /**
     # constraints
     - Author: Mephrine
     - Date: 20.07.12
     - Parameters:
     - Returns:
     - Note: 오토레이아웃 적용
    */
    func constraints() {
        self.searchBar.snp.makeConstraints { [weak self] in
            guard let self = self else { return }
            if #available(iOS 11.0, *) {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                $0.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
            $0.left.right.equalToSuperview()
            $0.height.equalTo(self.searchBar.bounds.height)
        }
        self.searchTableView.snp.makeConstraints{ [weak self] in
            guard let self = self else { return }
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(self.searchBar.snp.bottom)
        }
        
        self.noDataLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview().offset(-40)
        }
        
        self.noDataView.snp.makeConstraints { [weak self] in
            guard let self = self else { return }
            $0.left.equalTo(self.searchTableView.snp.left)
            $0.right.equalTo(self.searchTableView.snp.right)
            $0.bottom.equalTo(self.searchTableView.snp.bottom)
            $0.top.equalTo(self.searchTableView.snp.top)
        }
    }
}



