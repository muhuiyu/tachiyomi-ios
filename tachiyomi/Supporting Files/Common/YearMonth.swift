//
//  YearMonth.swift
//  Money Tracker
//
//  Created by Grace, Mu-Hui Yu on 7/30/23.
//

import Foundation

struct YearMonth: Comparable {
    var year: Int
    var month: Int
}
extension YearMonth {
    init(date: Date) {
        self.year = date.year
        self.month = date.month
    }
}
extension YearMonth {
    var isCurrentMonth: Bool {
        return self.year == Date.today.year && self.month == Date.today.month
    }
    static var now: YearMonth {
        return YearMonth(date: Date())
    }
}
extension YearMonth {
    func toDate(dayOfMonth: Int = 1) -> Date? {
        YearMonthDay(year: self.year, month: self.month, day: dayOfMonth).toDate
    }
    var toMonthAndYearString: String? {
        self.toDate()?.toMonthAndYearString
    }
    var nextMonth: YearMonth {
        if month == 12 {
            return YearMonth(year: self.year+1, month: 1)
        } else {
            return YearMonth(year: self.year, month: self.month+1)
        }
    }
    var previousMonth: YearMonth {
        if month == 1 {
            return YearMonth(year: self.year-1, month: 12)
        } else {
            return YearMonth(year: self.year, month: self.month-1)
        }
    }
    func getMonthString() -> String {
        return Date.MonthInNumber(rawValue: self.month)?.name ?? ""
    }
}
extension YearMonth {
    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        return lhs.month < rhs.month
    }
}
