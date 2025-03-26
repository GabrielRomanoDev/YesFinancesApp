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
    
    
    func filterTransactions(transactions: [any Transactions], parameters: FilteringParameters?, monthDisplayed: MonthDate) -> [any Transactions] {
        
        if let parameters = parameters {
            self.parameters = parameters
        }
        
        self.filteredTransactions = transactions
        
        if self.parameters.dates.enabled {
            dateFiltering()
        } else {
            self.filteredTransactions = filterTransactionsByMonth(monthDate: monthDisplayed)
        }
        
        typeFiltering()
        sourceFiltering()
        categoriesFiltering()
        valueFiltering()
        
        return self.filteredTransactions ?? []
        
    }
    
    func searchForTransactions(_ text: String?, transactions: [any Transactions]) -> [any Transactions] {
        
        if let text, !text.isEmpty {
            
            let arrayTransactions = transactions.filter { $0.desc.localizedCaseInsensitiveContains(text) }
            
            return arrayTransactions
            
        } else {
            return transactions
        }
        
    }
    
    private func typeFiltering() {
        
        guard let filteredTransactions else { return }
        
        if parameters.types.incomes && parameters.types.expenses {
            return
        }
        
        if parameters.types.expenses {
            
            self.filteredTransactions = filteredTransactions.filter { transaction in
                return transaction.amount < 0
            }
            
        }
        
        if parameters.types.incomes {
            
            self.filteredTransactions = filteredTransactions.filter { transaction in
                return transaction.amount > 0
            }
            
        }
        
    }
    
    private func sourceFiltering() {
        
        guard let filteredTransactions, let accountsSelection = parameters.accounts else { return }
        
        self.filteredTransactions = filteredTransactions.filter { transaction in
            accountsSelection.contains { account in
                return account.id == transaction.sourceId
            }
        }
        
    }
    
    private func categoriesFiltering() {
        
        guard let filteredTransactions else { return }
        
        if let categoriesSelection = parameters.categories {
            
            self.filteredTransactions = filteredTransactions.filter { transaction in
                categoriesSelection.contains { category in
                    return category.name == CategoriesRepository.shared.expenses[transaction.categoryIndex].name
                    
                }
            }
            
            
        }
        
    }
    
    private func valueFiltering() {
        
        guard let filteredTransactions else { return }
        
        guard parameters.limits.enabled else {
            return
        }
        
        self.filteredTransactions = filteredTransactions.filter { transaction in
            return abs(transaction.amount) > parameters.limits.min && abs(transaction.amount) < parameters.limits.max
        }
        
    }
    
    private func dateFiltering() {
        
        guard let filteredTransactions else { return }
        
        guard parameters.dates.enabled, let initialDate = parameters.dates.initial.toDate(), let finalDate = parameters.dates.final.toDate() else {
            return
        }
        
        self.filteredTransactions = filteredTransactions.filter { transaction in
            guard let date = transaction.date.toDate() else { return false }
            return date >= initialDate && date <= finalDate
        }
        
    }
    
    private func filterTransactionsByMonth(monthDate: MonthDate) -> [any Transactions] {
        guard let filteredTransactions else { return [] }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = globalStrings.dateFormat
        
        return filteredTransactions.filter {
            guard let date = dateFormatter.date(from: $0.date) else { return false }
            let components = Calendar.current.dateComponents([.month, .year], from: date)
            return components.month == monthDate.month && components.year == monthDate.year
        }
    }
    
}

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
