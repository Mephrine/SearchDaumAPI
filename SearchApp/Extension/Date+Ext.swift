//
//  Date+Ext.swift
//  SearchApp
//
//  Created by Mephrine on 2020/07/14.
//  Copyright © 2020 Mephrine. All rights reserved.
//

import Foundation

extension Date {
    
    // 날짜 계산은 UTC. 보여줄 때는 해당 타임존으로.
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
//        calendar.locale = Locale.init(identifier: "ko")
        return calendar
    }
    
    var dayDifference: String {
        if calendar.isDateInYesterday(self) { return "어제" }
        else if calendar.isDateInToday(self) { return "오늘" }
        else {
            return dateToString()
        }
    }
    
    func dateToString(format: String = "yyyy년 MM월 dd일") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: -9 * 60 * 60)
        formatter.locale = Locale.init(identifier: "ko")
        return formatter.string(from: self)
    }
}

