//
//  TransactionsFilterWorker.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 28/09/24.
//

import Foundation

class TransactionsFilterWorker {
    
    var filteredTransactions: [Transactions] = []
    var parameters: FilteringParameters = FilteringParameters()
    
    
    func filterTransactions(parameters: FilteringParameters) -> [Transactions] {
        
        self.filteredTransactions = TransactionsRepository.shared.list
        self.parameters = parameters
        
        typeFiltering()
        sourceFiltering()
        categoriesFiltering()
        valueFiltering()
        dateFiltering()
        return self.filteredTransactions
        
    }
    
    func searchForTransactions(_ text: String?) -> [Transactions] {
        
        if self.filteredTransactions.isEmpty {
            self.filteredTransactions = TransactionsRepository.shared.list
        }
        
        if let text, !text.isEmpty {
            
            let arrayTransactions = filteredTransactions.filter { $0.desc.localizedCaseInsensitiveContains(text) }
            
            return arrayTransactions
            
        } else {
            return filteredTransactions
        }
        
    }
    
    private func typeFiltering() {
        
        guard parameters.types.incomes || parameters.types.expenses else {
            return
        }
        
        if !parameters.types.incomes {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                transaction.amount < 0
            }
            
        }
        
        if !parameters.types.expenses {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                transaction.amount > 0
            }
            
        }
        
    }
    
    private func sourceFiltering() {
        
        if let accountsSelection = parameters.accounts {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                accountsSelection.contains { account in
                    account.id == transaction.accountId
                    
                }
            }
            
        }
        
        //        if let creditCardsSelection = creditCards {
        //
        //            filteredTransactions = filteredTransactions.filter { transaction in
        //                creditCardsSelection.contains(transaction.cardId)
        //            }
        //
        //        }
        
    }
    
    private func categoriesFiltering() {
        
        if let categoriesSelection = parameters.categories {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                categoriesSelection.contains { category in
                    category.name == CategoriesRepository.shared.expenses[transaction.categoryIndex].name
                    
                }
            }
            
            
        }
        
    }
    
    private func valueFiltering() {
        
        guard parameters.limits.enabled else {
            return
        }
        
        filteredTransactions = self.filteredTransactions.filter { transaction in
            abs(transaction.amount) > parameters.limits.min && abs(transaction.amount) < parameters.limits.max
        }
        
    }
    
    private func dateFiltering() {
        
        guard parameters.dates.enabled, let initialDate = parameters.dates.initial.toDate(), let finalDate = parameters.dates.final.toDate() else {
            return
        }
        
        filteredTransactions = self.filteredTransactions.filter { transaction in
            if let date = transaction.date.toDate() {
                return date >= initialDate && date <= finalDate
            }
            return false
        }
        
    }
    
    private func filterTransactionsByMonth(transactions: [Transactions], month: Int, year: Int) -> [Transactions] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = globalStrings.dateFormat
        
        let filteredTransactions = transactions.filter { transaction in
            if let date = dateFormatter.date(from: transaction.date) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.month, .year], from: date)
                return components.month == month && components.year == year
            }
            return false
        }
        
        return filteredTransactions
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
    var creditCard: Bool
    
    init(incomes: Bool = false, expenses: Bool = false, creditCard: Bool = false) {
        self.incomes = incomes
        self.expenses = expenses
        self.creditCard = creditCard
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
