//
//  WebPageViewController.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/15.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import UIKit
import ReactorKit
import Reusable
import WebKit
import RxCocoa

final class WebPageViewController: BaseViewController, StoryboardView, StoryboardBased {
    //MARK: - let
    let isWebBouncing = false           // 웹뷰 바운싱
    var isWebPopGesture = true
    
    // 웹뷰 설정
    private var config: WKWebViewConfiguration?
    private var webView: WKWebView!
    private var subWebView: WKWebView?
    
    weak var documentPicker: UIDocumentPickerViewController?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        webView.removeFromSuperview()
        webView = nil
    }
    
    override func initView() {
        //navi
        let button = UIButton(frame: CGRect.zero)
        button.addTarget(reactor, action: #selector(reactor?.goBack), for: .touchUpInside)
        button.setImage(UIImage(named: "navi_back"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 27)
                
        let naviItem = UIBarButtonItem.init(customView: button)
        naviItem.customView?.snp.makeConstraints{
            $0.width.height.equalTo(40)
        }
        
        self.navigationItem.leftBarButtonItem = naviItem
        
        //webview
        if let config = self.config {
            self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        } else {
            let config = WKWebViewConfiguration()
//            config.processPool = WKCookieStorage.shared.sharedProcessPool
            config.preferences.javaScriptEnabled = true
            config.preferences.javaScriptCanOpenWindowsAutomatically = true
            config.selectionGranularity = .character
            
            self.config = config
            self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        }
        
        
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        
        webView.scrollView.bounces = isWebBouncing
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.allowsBackForwardNavigationGestures = self.isWebPopGesture
        
        // 드래그로 키패드 내리기.
        webView.scrollView.keyboardDismissMode = .onDrag
        
        self.view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(reactor: WebPageViewModel) {
        Observable.just(Reactor.Action.loadView)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{ $0.url }
            .filterNil()
            .observeOn(Schedulers.main)
            .map{ URLRequest(url: $0) }
            .subscribe(onNext: { [weak self] in
                self?.webView?.load($0)
            })
            .disposed(by: disposeBag)
    }
    
    /**
     # isURLError
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
        - error : 발생한 URL 에러
     - Returns:
     - Note: URL 에러 처리가 필요한 에러가 맞는지 확인하는 함수.
    */
    private func isURLError(error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.code == -1022 {
            log.e("Error Code -1022 :: \(NSURLErrorAppTransportSecurityRequiresSecureConnection)")
            return true
        } else if nsError.code == 102 {
            // 스키마가 들어오는 경우 해당 부분이 실행됨.
            return false
        }  else if let urlError = error as? URLError {
            switch urlError.code {
            case .cancelled:
                return false
            case .notConnectedToInternet:
                log.e("Error Code notConnectedToInternet :::: \(urlError.code)")
                return true
            case .cannotFindHost:
                log.e("Error Code cannotFindHost :::: \(urlError.code)")
                return true
            case .resourceUnavailable:
                log.e("Error Code resourceUnavailable")
                return true
            case .timedOut:
                log.e("Error Code timedOut")
                return true
            default:
                return true
            }
        }
        return true
    }
    
    /**
     # chkURLError
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
        - error : 발생한 URL 에러
     - Returns:
     - Note: URL Error 발생 시 사용자에게 보여줄 내용을 정리한 함수.
    */
    func chkURLError(_ error: Error) {
        if isURLError(error: error) {
            LoadingView.shared.hide()
            self.onErrorCoverView()
            self.showErrorConfirm()
        }
    }
    
    /**
     # dismiss
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
     - Returns:
     - Note: WebView내에서 UIDocumentPickerViewController 오픈 시, dismiss 관련 버그로 인해서 추가.
    */
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if self.presentedViewController == nil && self.documentPicker != nil {
            self.documentPicker = nil
        } else {
            super.dismiss(animated: flag, completion: completion);
        }
    }
    
    /**
     # present
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
        - urlString : 호출할 URL String형
        - parameters : 파라미터
     - Returns:
     - Note: 웹뷰 URL 호출 시 사용되는 함수.
    */
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent is UIDocumentPickerViewController {
            self.documentPicker = viewControllerToPresent as? UIDocumentPickerViewController
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    /**
     # callJavaScriptFunc
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
        - funcStr : JavaScript String
        - completion : 스크립트 실행 후 CompletionHandler
     - Returns:
     - Note: 스크립트 실행 함수.
     */
    func callJavaScriptFunc(_ funcStr: String, completion: ((Any?, Error?) -> Void)? = nil) {
        webView.evaluateJavaScript(funcStr, completionHandler: completion)
    }
    
    /**
     # onErrorCoverView
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
     - Returns:
     - Note: 웹뷰내 에러가 발생한 경우, 웹뷰 내용을 숨기기 위해서 흰색 뷰를 덮어 씌움.
     */
    func onErrorCoverView() {
        // 기존에 해당 뷰가 존재하는지 체크.
        let existView: UIView? = self.view.viewWithTag(999)
        if existView != nil {
            return
        }
       
        let coverView = UIView()
        coverView.backgroundColor = UIColor(hex:0xffffff)
        coverView.tag = 999
        self.view.addSubview(coverView)
        
        coverView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
    /**
     # onErrorCoverRemoveView
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
     - Returns:
     - Note: 웹뷰내 에러가 발생한 경우, 웹뷰 내용을 숨기기 위해서 덮은 흰색 뷰를 제거.
     */
    func onErrorCoverRemoveView() {
        // 기존에 해당 뷰가 존재하는지 체크.
        if let existView: UIView? = self.view.viewWithTag(999) {
            existView?.removeFromSuperview()
        }
    }
    
    /**
     # showErrorConfirm
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
     - Returns:
     - Note: 웹뷰 오류 리로드 알럿 띄우기.
     */
    func showErrorConfirm() {
        CommonAlert.showConfirm(vc: self, message: STR_WEBVIEW_ERROR_RELOAD, cancelTitle: STR_CANCEL, completeTitle: STR_OK, { [weak self] in
            self?.onErrorCoverRemoveView()
        }, { [weak self] in
            self?.onErrorCoverRemoveView()
            self?.webView.reload()
        })
    }

    /**
        # deallocSubWebView
        - Author: Mephrine
        - Date: 20.06.10
        - Parameters:
        - Returns:
        - Note: window.open으로 생성한 subWebView 메모리 할당 해제하는 함수.
    */
    func deallocSubWebView() {
        LoadingView.shared.hide()
        subWebView?.stopLoading()
        subWebView?.loadHTMLString("", baseURL: nil)
        subWebView?.uiDelegate = nil
        subWebView?.navigationDelegate = nil
        subWebView?.removeFromSuperview()
        subWebView = nil
    }
    
    /**
        # popGesture
        - Author: Mephrine
        - Date: 20.06.10
        - Parameters:
        - Returns:
        - Note: PopGesture시 실행되는 함수
    */
    override func popGesture() {
        reactor = nil
    }
}

extension WebPageViewController: WKNavigationDelegate {
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
       LoadingView.shared.show()
    }
    
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // 전달된 URL
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if reactor?.decidePolicyFor(url: url) ?? false {
            decisionHandler(.allow)
        } else {
            LoadingView.shared.hide()
            decisionHandler(.cancel)
        }
    }
    
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingView.shared.hide()
    }
    
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        log.e("스크립트 에러 :  \(error.localizedDescription)")
        LoadingView.shared.hide()
    }
}

extension WebPageViewController: WKUIDelegate {
    /**
     # webView
     - Author: Mephrine
     - Date: 20.07.15
     - Parameters:
        - webView : 웹뷰
        - runJavaScriptAlertPanelWithMessage : 알럿에 노출될 메시지
        - initiatedByFrame : 해당 뷰 프레임
        - completionHandler : 확인 버튼 누를 시 실행될 핸들러
     - Returns: WKWebView
     - Note: 웹에서 alert 호출 시 실행되는 함수.
     */
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if webView.url?.host != nil {
            CommonAlert.showAlert(vc: self, message: message, completionHandler)
        } else {
            completionHandler()
        }
        
    }
    
    /**
     # webView
     - Author: Mephrine
     - Date: 20.07.15
     - Parameters:
        - webView : 웹뷰
        - runJavaScriptConfirmPanelWithMessage : confirm창에 노출될 메시지
        - initiatedByFrame : 해당 뷰 프레임
        - completionHandler : 확인 / 취소 버튼 누를 시 실행될 핸들러
     - Returns: WKWebView
     - Note: 웹에서 confirm 호출 시 실행되는 함수.
     */
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if webView.url?.host != nil {
            CommonAlert.showJSConfirm(vc: self, message: message, completionHandler)
        } else {
            completionHandler(true)
        }
    }
    
    /**
     # webView
     - Author: Mephrine
     - Date: 20.07.15
     - Parameters:
        - webView : 새 창 웹뷰
        - createWebViewWith : 웹뷰 설정
        - for : 웹뷰 action
        - windowFeatures : 새 창의 window 특성
     - Returns: WKWebView
     - Note: 웹에서 window.open등 새 창을 열면 실행되는 함수.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        // window.open 등의 새창을 실행하는 스크립트가 실행되면 해당 부분을 탐.
        // webView를 리턴하면 해당 함수 내부에서 post등의 관련 데이터를 전달하는 것으로 보임. 그래서 request url 로그를 찍으면 nil로 들어옴.
        if navigationAction.targetFrame == nil {
            configuration.userContentController = WKUserContentController()
            subWebView = WKWebView(frame: CGRect.zero, configuration: configuration)
            self.view.addSubview(subWebView!)
            subWebView?.snp.makeConstraints{
                $0.edges.equalToSuperview()
            }
            subWebView?.uiDelegate = self
            subWebView?.navigationDelegate = self
            
            return subWebView
        }
        return WKWebView(frame: view.bounds, configuration: configuration)
    }
    
    /**
     # webView
     - Author: Mephrine
     - Date: 20.07.15
     - Parameters:
        - webView : 새 창 웹뷰
        - shouldPreviewElement : 프리뷰 내용
     - Returns: WKWebView
     - Note: 웹 프리뷰 설정.
     */
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
    
    /**
     # webViewDidClose
     - Author: Mephrine
     - Date: 20.07.15
     - Parameters:
        - webView : 새 창이 닫힐 때의 웹뷰
     - Returns: WKWebView
     - Note: window.close로 새 창이 닫히는 스크립트 실행 시 호출되는 함수.
     */
    /** @abstract Notifies your app that the DOM window object's close() method completed successfully.
     @param webView The web view invoking the delegate method.
     @discussion Your app should remove the web view from the view hierarchy and update
     the UI as needed, such as by closing the containing browser tab or window.
     */
    @available(iOS 9.0, *)
    func webViewDidClose(_ webView: WKWebView) {
        self.deallocSubWebView()
    }
}
