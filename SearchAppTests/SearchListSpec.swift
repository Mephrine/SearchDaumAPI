//
//  SearchListSpec.swift
//  SearchAppTests
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Quick
import Nimble
import RxBlocking
import RxSwift
import RxTest
import RxCocoa
import RxOptional
@testable import SearchApp

class SearchListSpec: QuickSpec {
    override func spec() {
        var service: SearchServiceProtocol!
        var disposeBag: DisposeBag!
        // 모든 example가 실행되기 전에 실행.
        beforeSuite {
            service = SearchServiceStub()
            disposeBag = DisposeBag()
        }
        
        // 모든 example가 실행되고난 후에 실행.
        afterSuite {
            
        }
        
        
        describe("Request search API : cafe") {
            context("Check API for result value") {
                it("Check first item name is correct") {
                    do {
                        let searchBlog = try service.fetchSearchCafe("", .accuracy, 1).toBlocking().first()
                        expect(searchBlog?.items?.first?.name!).to(equal("＊여성시대＊ 차분한 20대들의 알흠다운 공간"), description: "firstName is 여성시대.")
                    } catch let error {
                        print("error### : \(error)")
                        fail("searchUser blocking error")
                    }
                }
            }
        }
        
        
        describe("Request search API : blog") {
            context("Check API for result value") {
                it("Check first item name is correct") {
                    do {
                        let searchBlog = try service.fetchSearchBlog("", .accuracy, 1).toBlocking().first()
                        expect(searchBlog?.items?.first?.name!).to(equal("핑크빛 장미"), description: "firstName is 여성시대.")
                    } catch let error {
                        print("error### : \(error)")
                        fail("searchUser blocking error")
                    }
                }
            }
        }
        
    }
}

