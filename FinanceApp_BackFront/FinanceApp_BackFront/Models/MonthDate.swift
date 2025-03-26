//
//  MonthDate.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 02/03/25.
//

struct MonthDate: Codable, Equatable {
    var month: Int
    var year: Int
    
    init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
    
    mutating func nextMonth() {
        self.month += 1
        if self.month > 12 {
            self.month = 1
            self.year += 1
        }
    }
    
    mutating func lastMonth() {
        self.month -= 1
        if self.month < 1 {
            self.month = 12
            self.year -= 1
        }
    }
    
}
