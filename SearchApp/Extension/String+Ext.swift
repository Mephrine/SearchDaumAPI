//
//  String+Ext.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/12.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import UIKit

extension String {
    func index(at offset: Int, from start: Index? = nil) -> Index? {
        return index(start ?? startIndex, offsetBy: offset, limitedBy: endIndex)
    }
    
    var trimTrailingWhitespace: String {
        if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingWs, with: "")
        } else {
            return self
        }
    }
    
    var trimSide: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func toDate(_ format: String = "yyyy-MM-dd'T'hh:mm:ss'.000'xxx") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter.date(from: self) ?? Date()
    }
    
    func toNearDateStr(format: String = "yyyy-MM-dd'T'hh:mm:ss'.000'xxx") -> String {
        return self.toDate().dayDifference
    }
    
    func toDateKr(format: String = "yyyy-MM-dd'T'hh:mm:ss'.000'xxx") -> String {
        return self.toDate().dateToString(format: "yyyy년 MM월 dd일 a HH시 mm분")
    }
    
    func htmlAttributedString(font: UIFont) -> NSAttributedString? {
        
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }

        guard let html = try? NSMutableAttributedString(
                                        data: data,
                                     options: [.documentType: NSAttributedString.DocumentType.html],
                                     documentAttributes: nil) else {
            return nil
        }
        
        html.addAttribute(.font, value: font, range: NSMakeRange(0, html.string.utf16.count))

        return html
    }
    
    
    //MARK: - SubScript
    subscript(_ range: CountableRange<Int>) -> Substring {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        return self[start..<(index(at: range.count, from: start) ?? endIndex)]
    }
    subscript(_ range: CountableClosedRange<Int>) -> Substring {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        return self[start..<(index(at: range.count, from: start) ?? endIndex)]
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1].string
    }
}


extension Substring {
    var string: String { return String(self) }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    public var removingAllWhitespacesAndNewlines: Self {
        return filter { !$0.isNewline && !$0.isWhitespace }
    }
}
