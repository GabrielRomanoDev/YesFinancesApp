//
//  FilteringTransactionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/08/24.
//

import Foundation

class FilteringTransactionsViewModel {
    
    var filteredTransactions: [Transactions]
    var types: TransactionFilteringTypes? = nil
    var accounts: [String]? = nil
    var creditCards: [String]? = nil
    var categories: [String]? = nil
    var limits: TransactionFilteringValue? = nil
    var dates: TransactionFilteringDates? = nil
    
    init() {
        self.filteredTransactions = transactionsList
    }
    
    
    func filterTransactions() -> [Transactions] {

        typeFiltering()
        sourceFiltering()
        categoriesFiltering()
        valueFiltering()
        dateFiltering()
        
        return filteredTransactions
        
    }
    
    private func typeFiltering() {
        
        guard let types = self.types, types.incomes || types.expenses else {
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
        
        if let accountsSelection = accounts {
            
            filteredTransactions = filteredTransactions.filter { transaction in
                accountsSelection.contains(transaction.accountId)
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
        
        if let categoriesSelection = categories {
            
            filteredTransactions = filteredTransactions.filter { transaction in
//                switch transaction.type {
//                case .expense:
//                    categoriesSelection.contains(transaction.categoryIndex)
//                case .income:
//                    categoriesSelection.contains(transaction.categoryIndex+expenseCategories.count)
//                }
                categoriesSelection.contains(transaction.desc)
            }
            
        }
        
    }
    
    private func valueFiltering() {
        
        guard let limits = limits else {
            return
        }
        
        filteredTransactions = self.filteredTransactions.filter { transaction in
            abs(transaction.amount) > limits.min && abs(transaction.amount) < limits.max
        }
        
    }
    
    private func dateFiltering() {
        
        guard let dates = self.dates, let from = stringToDate(dates.from), let to = stringToDate(dates.to) else {
            return
        }
        
        filteredTransactions = self.filteredTransactions.filter { transaction in
            if let date = stringToDate(transaction.date) {
                return date >= from && date <= to
            }
            return false
        }
        
    }
    

    
    private func stringToDate(_ dateString: String?, format: String = "dd-MM-yyyy") -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let date = dateString {
            return dateFormatter.date(from: date)
        } else {
            return nil
        }
        
    }
    
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

//    private func filterTransactionsByMonth(transactions: [Transactions], month: Int, year: Int) -> [Transactions] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = globalStrings.dateFormat
//
//        let filteredTransactions = transactions.filter { transaction in
//            if let date = dateFormatter.date(from: transaction.date) {
//                let calendar = Calendar.current
//                let components = calendar.dateComponents([.month, .year], from: date)
//                return components.month == month && components.year == year
//            }
//            return false
//        }
//
//        return filteredTransactions
//    }


// Criar uma segunda variável com as transações filtradas para o mês atual (julho de 2024)
//filteredTransactions = filterTransactionsByMonth(transactions: transactionsList, month: 6, year: 2024)
