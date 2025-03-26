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
    
}

extension Int {
    
    func getNextDate() -> Date {
        return Calendar.current.date(bySetting: .day, value: self, of: Date()) ?? Date()
    }
    
}
