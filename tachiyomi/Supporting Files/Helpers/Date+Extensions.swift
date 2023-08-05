//
//  Date+Extensions.swift
//  Fastiee
//
//  Created by Mu Yu on 6/27/22.
//

import Foundation

// MARK: - Get certain day
extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month],
                                                                           from: Calendar.current.startOfDay(for: self)))!
    }
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1),
                                     to: self.startOfMonth())!
    }
    var dayBefore: Date { self.day(before: 1) }
    var dayAfter: Date { self.day(after: 1) }
    
    func day(before numberOfDays: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -numberOfDays, to: noon)!
    }
    func day(after numberOfDays: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: numberOfDays, to: noon)!
    }
    
    var monthBefore: Int { self.month == 1 ? 12 : self.month + 1 }
    var monthAfter: Int { self.month == 12 ? 1 : self.month + 1 }
    
    var noon: Date { Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)! }
    var year: Int { Calendar.current.component(.year, from: self) }
    var month: Int { Calendar.current.component(.month, from: self) }
    var dayOfMonth: Int { Calendar.current.component(.day, from: self) }
    var hour: Int { Calendar.current.component(.hour, from: self) }
    var minute: Int { Calendar.current.component(.minute, from: self) }
    var second: Int { Calendar.current.component(.second, from: self) }
    
    var toYearMonthDay: YearMonthDay { return YearMonthDay(year: year, month: month, day: dayOfMonth) }
    
    func getDateInThisWeek(on weekday: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let weekDayOfToday = calendar.component(.weekday, from: self)
        return self.day(before: weekDayOfToday - weekday)
    }
    
    static var today: Date { Date() }
    static var currentDay: Int { Date().dayOfMonth }
    static var currentMonth: Int { Date().month }
    static var currentYear: Int { Date().year }
    
    var firstDayOfMonth: Date { self.day(before: self.dayOfMonth-1) }
    var numberOfDaysRemainingToEndOfMonth: Int {
        return Date.getNumberOfDays(year: year, month: month) - dayOfMonth + 1
    }
}
// MARK: - Get certain time
extension Date {
    func date(beforeHours numberOfHours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: -numberOfHours, to: self)!
    }
    func date(afterHours numberOfHours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: numberOfHours, to: self)!
    }
    func date(beforeMinutes numberOfMinutes: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: -numberOfMinutes, to: self)!
    }
    func date(afterMinutes numberOfMinutes: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: numberOfMinutes, to: self)!
    }
}

// MARK: - Verification
extension Date {
    static func isLeapYear(year: Int) -> Bool {
        return year.isMultiple(of: 400) || (!year.isMultiple(of: 100) && year.isMultiple(of: 4))
    }
    static func isValid(year: Int, month: Int, day: Int) -> Bool {
        guard year > 0, month > 0, month <= 12, day > 0 else { return false }
        
        switch month {
        case MonthInNumber.january.rawValue,
            MonthInNumber.march.rawValue,
            MonthInNumber.may.rawValue,
            MonthInNumber.july.rawValue,
            MonthInNumber.august.rawValue,
            MonthInNumber.october.rawValue,
            MonthInNumber.december.rawValue: return day <= 31
        case MonthInNumber.april.rawValue,
            MonthInNumber.june.rawValue,
            MonthInNumber.september.rawValue,
            MonthInNumber.november.rawValue: return day <= 30
        case MonthInNumber.february.rawValue:
            if isLeapYear(year: year) {
                return day <= 29
            } else {
                return day <= 28
            }
        default: return false
        }
    }
    static func getNumberOfDays(year: Int, month: Int) -> Int {
        guard let month = MonthInNumber(rawValue: month) else { return 31 }
        if month == .december { return 31 }
        return YearMonthDay(year: year, month: month.rawValue+1, day: 1).toDate?.dayBefore.dayOfMonth ?? 31
    }
    static func isValid(month: Int) -> Bool {
        return month >= 1 && month <= 12
    }
    enum MonthInString: String {
        case january
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
    }
    
    enum MonthInNumber: Int {
        case january = 1
        case february = 2
        case march = 3
        case april = 4
        case may = 5
        case june = 6
        case july = 7
        case august = 8
        case september = 9
        case october = 10
        case november = 11
        case december = 12
        
        var name: String {
            switch self {
            case .january:
                return "January"
            case .february:
                return "February"
            case .march:
                return "March"
            case .april:
                return "April"
            case .may:
                return "May"
            case .june:
                return "June"
            case .july:
                return "July"
            case .august:
                return "August"
            case .september:
                return "September"
            case .october:
                return "October"
            case .november:
                return "November"
            case .december:
                return "December"
            }
        }
    }
    
    static func getMonthString(from month: Int) -> String? {
        guard let month = MonthInNumber(rawValue: month) else { return nil }
        return month.name
    }
    
    enum Weekday: Int {
        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
        
        var name: String {
            switch self {
            case .monday:
                return "Monday"
            case .tuesday:
                return "Tuesday"
            case .wednesday:
                return "Wednesday"
            case .thursday:
                return "Thursday"
            case .friday:
                return "Friday"
            case .saturday:
                return "Saturday"
            case .sunday:
                return "Sunday"
            }
        }
    }
}

// MARK: - Determine
extension Date {
    var isFirstDayOfMonth: Bool { dayOfMonth == 1 }
    var isLastDayOfMonth: Bool { dayAfter.month != month }
    func isTodayWeekend() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let weekDay = calendar.component(.weekday, from: self)
        return (weekDay == 1 || weekDay == 7)
    }
    func isToday(weekDay: Int) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let todayWeekDay = calendar.component(.weekday, from: self)
        return (todayWeekDay == weekDay)
    }
}

// MARK: - Date Formatter
extension Date {
    func formatted() -> String {
        return self.formatted(.dateTime.year().month().day())
    }
    var toMonthAndYearString: String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM yyyy"
        return dateFormatterPrint.string(from: self)
    }
    func toWeekDayAndDayString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        let weekDay = Calendar.current.component(.weekday, from: self)
        return dateFormatterPrint.weekdaySymbols[weekDay - 1] + ", " + dateFormatterPrint.string(from: self)
    }
    func toWeekDayString(formatStyle: Date.FormatStyle.Symbol.Weekday = .abbreviated) -> String {
        return self.formatted(Date.FormatStyle().weekday(formatStyle))
    }
    func toWeekDayAndDayWithoutYearString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd"
        let weekDay = Calendar.current.component(.weekday, from: self)
        return dateFormatterPrint.weekdaySymbols[weekDay - 1] + ", " + dateFormatterPrint.string(from: self)
    }
    var toMonthDayYearString: String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        return dateFormatterPrint.string(from: self)
    }
    var toMonthAndDayString: String? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd"
        return dateFormatterPrint.string(from: self)
    }
    func toYearMonthDayAndTimeString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateFormatterPrint.string(from: self)
    }
    func toHistoryID() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        return dateFormatterPrint.string(from: self) + "-history-entry"
    }
}

// MARK: - Calculate
extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

//// MARK: - YearMonthDay
//extension Date {
//    var toDateAndTime: DateAndTime { DateAndTime(year: self.year, month: self.month, day: self.dayOfMonth, hour: self.hour, minute: self.minute, second: self.second) }
//}
