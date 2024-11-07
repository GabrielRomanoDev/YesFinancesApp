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
        
        self.filteredTransactions = transactionsList
        self.parameters = parameters
        
        typeFiltering()
        sourceFiltering()
        categoriesFiltering()
        valueFiltering()
        dateFiltering()
        
        return filteredTransactions
        
    }
    
    private func typeFiltering() {
        
        guard let types = self.parameters.types, types.incomes || types.expenses else {
            return
        }
        
        if !types.incomes {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                transaction.amount < 0
            }
            
        }
        
        if !types.expenses {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                transaction.amount > 0
            }
            
        }
        
    }
    
    private func sourceFiltering() {
        
        if let accountsSelection = parameters.accounts {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                accountsSelection.contains { account in
                    account.getId == transaction.accountId
                    
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
                categoriesSelection.contains(transaction.desc)
            }
            
        }
        
    }
    
    private func valueFiltering() {
        
        guard let limits = parameters.limits else {
            return
        }
        
        filteredTransactions = self.filteredTransactions.filter { transaction in
            abs(transaction.amount) > limits.min && abs(transaction.amount) < limits.max
        }
        
    }
    
    private func dateFiltering() {
        
        guard let dates = self.parameters.dates, let from = dates.from.toDate(), let to = dates.to.toDate() else {
            return
        }
        
        filteredTransactions = self.filteredTransactions.filter { transaction in
            if let date = transaction.date.toDate() {
                return date >= from && date <= to
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
    
    var types: TransactionFilteringTypes? = nil
    var accounts: [BankAccount]? = nil
    var creditCards: [String]? = nil
    var categories: [String]? = nil
    var limits: TransactionFilteringValue? = nil
    var dates: TransactionFilteringDates? = nil
    
}

struct TransactionFilteringValue {
    
    var min: Double
    var max: Double
    
    init(min: Double = 0.0, max: Double = 0.0) {
        self.min = min
        self.max = max
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
    
    var from: String
    var to: String
    
    init(from: String, to: String) {
        self.from = from
        self.to = to
    }
    
}
