//
//  TouchDownGestureRecognizer.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/15.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import UIKit

class TouchDownGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
}
