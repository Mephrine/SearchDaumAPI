//
//  LoadingView.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/15.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import UIKit

/**
    # (C) LoadingView
    - Author: Mephrine
    - Date: 20.07.15
    - Note: 로딩 화면 뷰
   */
final class LoadingView: UIView {
    
    // 컴포넌트
    static let shared = LoadingView()
//    private var isLoading: Bool = false
    private var loadingCnt: Int = 0
    
    /**
     # show
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
     - Returns:
     - Note: 로딩뷰 보이기
    */
    public func show() {
        loadingCnt += 1
        if loadingCnt > 1 {
            return
        }

        let LoadingImageView = UIImageView.init(frame: CGRect.zero)
        LoadingImageView.tag = 999

        LoadingImageView.backgroundColor = .clear
        LoadingImageView.animationImages = LoadingView.shared.animArray()   // 애니메이션 이미지
        LoadingImageView.animationDuration = 1.5
        LoadingImageView.animationRepeatCount = 0    // 0일 경우 무한반복

        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.5)
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                LoadingImageView.center = window.center
                self.addSubview(LoadingImageView)
                window.addSubview(self)
                
                LoadingImageView.snp.makeConstraints{
                    $0.centerX.centerY.equalToSuperview()
                }

                LoadingImageView.startAnimating()
            }
        }
    }

    /**
     # hide
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
     - Returns:
     - Note: 로딩뷰 숨기기
    */
    public func hide(_ completion: (() -> Void)? = nil) {
        loadingCnt -= 1
        if loadingCnt > 0 {
            return
        }
        
        DispatchQueue.main.async {
            if let LoadingImageView = self.viewWithTag(999) as? UIImageView {
                LoadingImageView.stopAnimating()
                LoadingImageView.removeFromSuperview()
                
                self.removeFromSuperview()
                completion?()
            }
        }
    }
    
    /**
     # animArray
     - Author: Mephrine
     - Date: 20.06.10
     - Parameters:
     - Returns: [UIImage]
     - Note: 로딩뷰로 보여질 UIImage 배열 반환
    */
    func animArray() -> [UIImage] {
        var animArray: [UIImage] = []
        for i in 0 ..< 30 {
            if let img = UIImage(named: "frame-\(i)") {
                animArray.append(img)
            }
        }
        
        return animArray
    }
}
