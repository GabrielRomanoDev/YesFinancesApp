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
}
