//
//  String.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/05/23.
//

import Foundation

extension String {
    func isEmptyTest() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func toDouble() -> Double {
        let valorString = self

        let valorNumericoString = valorString
            .replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)

        if let valorNumerico = Double(valorNumericoString) {
            return valorNumerico
        } else {
            return 0.0
        }
    }
    
    func toDate(format: String = globalStrings.dateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.timeZone = TimeZone.current
        
        if self == globalStrings.todayText {
            return Date()
        } else if self == globalStrings.yesterdayText {
            return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        } else if self == globalStrings.tomorrowText {
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())
        } else {
            return dateFormatter.date(from: self)
        }
    }
    
}
