//
//  Config.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//
import Foundation

struct ButtonsCellConfiguration {
    var configurationTitle: String
    var button1Title: String
    var button2Title: String
    var button1Value: Bool
    var button2Value: Bool
    
    init(filteringTypes: TransactionFilteringTypes?) {
        self.configurationTitle = FilteringTransactionsStrings.transactionType
        self.button1Title = FilteringTransactionsStrings.income
        self.button2Title = FilteringTransactionsStrings.expense
        self.button1Value = filteringTypes?.incomes ?? false
        self.button2Value = filteringTypes?.expenses ?? false
        
    }
}
