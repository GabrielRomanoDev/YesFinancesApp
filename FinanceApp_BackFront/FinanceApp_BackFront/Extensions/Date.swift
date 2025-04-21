//
//  Date.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 02/03/25.
//

import Foundation

extension Date {
    
    func getMonth() -> MonthDate {
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        
        return MonthDate(month: month, year: year)
        
    }
    
    func setDate(day: Int, month: MonthDate) -> Date {
        
        var valueDay: Int = day
        var valueMonth: Int = month.month
        
        if day < 1 {
            valueDay = 1
        } else  if day > 31 {
            valueDay = 28
        }
        
        if month.month < 1 {
            valueMonth = 1
        } else if month.month > 12 {
            valueMonth = 12
        }
        
        var components = DateComponents()
        components.day = valueDay
        components.month = valueMonth
        components.year = month.year
        
        return Calendar.current.date(from: components) ?? Date()
        
    }
    
    func dateWrittenString() -> String {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        var dataSelecionada = self
        
        switch dataSelecionada.toString(format: globalStrings.dateFormat) {
        case today.toString(format: globalStrings.dateFormat):
            return globalStrings.todayText
        case yesterday.toString(format: globalStrings.dateFormat):
            return globalStrings.yesterdayText
        case tomorrow.toString(format: globalStrings.dateFormat):
            return globalStrings.tomorrowText
        default:
            return self.toString(format: globalStrings.dateFormat)
        }
    }
    
    mutating func setMonth(month: MonthDate) {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.day], from: self)
        components.month = month.month
        components.year = month.year
        
        self = calendar.date(from: components) ?? Date()
    }
    
}

extension Int {
    
    func getNextDate() -> Date {
        return Calendar.current.date(bySetting: .day, value: self, of: Date()) ?? Date()
    }
    
}
