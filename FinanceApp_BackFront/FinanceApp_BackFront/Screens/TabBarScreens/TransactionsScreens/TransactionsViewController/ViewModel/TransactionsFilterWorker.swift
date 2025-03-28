//
//  TransactionsFilterWorker.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 28/09/24.
//

import Foundation

class TransactionsFilterWorker {
    
    var filteredTransactions: [any Transactions]? = nil
    var parameters: FilteringParameters = FilteringParameters()
    
    func filterTransactions(transactions: [any Transactions], parameters: FilteringParameters?, monthDisplayed: MonthDate? = nil) -> [any Transactions] {
        
        if let parameters = parameters {
            self.parameters = parameters
        }
        
        self.filteredTransactions = transactions
        
        let compositeSpec = CompositeSpecification()
        
        if self.parameters.dates.enabled {
            
            if let initial = self.parameters.dates.initial.toDate(), let final = self.parameters.dates.final.toDate() {
                compositeSpec.add(DateSpecification(initialDate: initial, finalDate: final))
            }
            
        } else {
            
            let monthSpec = MonthSpecification(monthDisplayed: monthDisplayed)
            compositeSpec.add(monthSpec)
            
        }
        
        compositeSpec.add( TypeSpecification(types: self.parameters.types) )
        
        if self.parameters.limits.enabled {
            compositeSpec.add( ValueSpecification(min: self.parameters.limits.min, max: self.parameters.limits.max) )
        }
        
        if let accounts = self.parameters.accounts {
            compositeSpec.add(SourceSpecification(accounts: accounts))
        }
        
        if let categories = self.parameters.categories {
            compositeSpec.add(CategorySpecification(categories: categories))
        }
        
        self.filteredTransactions = transactions.filter { compositeSpec.isSatisfied(by: $0) }
        
        return self.filteredTransactions ?? []
    }
    
    func searchForTransactions(_ text: String?, transactions: [any Transactions]) -> [any Transactions] {
        guard let text, !text.isEmpty else {
            return transactions
        }
        return transactions.filter { $0.desc.localizedCaseInsensitiveContains(text) }
    }
}
