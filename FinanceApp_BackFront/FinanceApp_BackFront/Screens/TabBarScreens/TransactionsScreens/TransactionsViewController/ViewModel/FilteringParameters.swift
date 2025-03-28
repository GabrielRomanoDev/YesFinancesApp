//
//  FilteringParameters.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 27/03/25.
//

import Foundation

struct FilteringParameters {
    
    var types: TransactionFilteringTypes = TransactionFilteringTypes()
    var accounts: [BankAccount]? = nil
    var creditCards: [CreditCard]? = nil
    var categories: [TransactionCategory]? = nil
    var limits: TransactionFilteringValue = TransactionFilteringValue()
    var dates: TransactionFilteringDates = TransactionFilteringDates()
    
}

struct TransactionFilteringValue {
    
    var min: Double
    var max: Double
    var enabled: Bool
    
    init(min: Double = 0.0, max: Double = 0.0, enabled: Bool = false) {
        self.min = min
        self.max = max
        self.enabled = enabled
    }
    
}

struct TransactionFilteringTypes {
    
    var incomes: Bool
    var expenses: Bool
    
    init(incomes: Bool = false, expenses: Bool = false) {
        self.incomes = incomes
        self.expenses = expenses
    }
    
}

struct TransactionFilteringDates {
    
    var initial: String
    var final: String
    var enabled: Bool
    
    init(initial: String = Date().toString(), final: String = Date().toString(), enabled: Bool = false) {
        self.initial = initial
        self.final = final
        self.enabled = enabled
    }
    
}
