//
//  SwitchExpandCellConfiguration.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//

import Foundation

struct SwitchExpandCellConfiguration {
    var configurationTitle: String
    var switchValue: Bool
    
    init(filteringDates: TransactionFilteringDates) {
        self.configurationTitle = FilteringTransactionsStrings.timeInterval
        self.switchValue = false
    }
    
    init(filteringValue: TransactionFilteringValue) {
        self.configurationTitle = FilteringTransactionsStrings.value
        self.switchValue = false
    }
}
