//
//  FilteringTransactionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/08/24.
//

import Foundation

class FilteringTransactionsViewModel {
    
    var parameters: FilteringParameters
    
    init(parameters: FilteringParameters?) {
        self.parameters = parameters ?? FilteringParameters()
    }
    
    
}
