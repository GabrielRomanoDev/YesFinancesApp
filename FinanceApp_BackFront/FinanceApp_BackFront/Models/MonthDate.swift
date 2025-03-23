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
}
