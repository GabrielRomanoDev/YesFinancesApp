//
//  TransactionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 20/04/23.
//

import Foundation

struct TransactionsViewModel {
    
    private var filteringWorker: TransactionsFilterWorker = TransactionsFilterWorker(filterType: .transactions)
    private var filteredTransactions: [any Transactions] = TransactionsRepository.shared.list
    private var pendingInvoices: [Invoice] = []
    private var monthDisplayed: MonthDate = MonthDate( month: Calendar.current.component(.month, from: Date() ), year: Calendar.current.component(.year, from: Date() ))
    
    public mutating func reordenateTransactions() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = globalStrings.dateFormat
        
        self.filteredTransactions = self.filteredTransactions.sorted(by: { transaction1, transaction2 in
            if let date1 = dateFormatter.date(from: transaction1.date), let date2 = dateFormatter.date(from: transaction2.date) {
                return date1 > date2
            }
            
            return true
        })
        
    }
    
    func getPendingInvoicesCount() -> Int {
        return pendingInvoices.count
    }
    
    func getTransactionsCount() -> Int {
        return filteredTransactions.count
    }
    
    func getItemInvoices(_ index: Int) -> Invoice {
        return pendingInvoices[index]
    }
    
    func getItemTransactions(_ index: Int) -> any Transactions {
        return filteredTransactions[index]
    }
    
    func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 85)
    }
    
    func getParameters() -> FilteringParameters {
        return filteringWorker.parameters
    }
    
    func deleteTransaction(_ filteredIndex: Int, completion: @escaping (String) -> Void) {
        
        if let index = TransactionsRepository.shared.list.firstIndex(where: {$0.id == filteredTransactions[filteredIndex].id}) {
            
            FirestoreService.shared.deleteObject(id: TransactionsRepository.shared.list[index].id, subCollection: firebaseSubCollectionNames.transactions) { result in
                TransactionsRepository.shared.list.remove(at: index)
                completion(result)
            }
            
        }
        
    }
    
    mutating func displayNextMonth() {
        
        monthDisplayed.nextMonth()
        filteringWorker.parameters.dates.enabled = false
        
    }
    
    mutating func displayLastMonth() {
        
        monthDisplayed.lastMonth()
        filteringWorker.parameters.dates.enabled = false
        
    }
    
    func getMonthName(dateFilter: TransactionFilteringDates? = nil) -> String {
        
        if let date = dateFilter, date.enabled {
            return "\(date.initial) - \(date.final)"
        }
        
        if monthDisplayed.year == Calendar.current.component(.year, from: Date()) {
            return monthsText[monthDisplayed.month] ?? globalStrings.january
        } else {
            return "\(monthsText[monthDisplayed.month] ?? globalStrings.january) \(monthDisplayed.year)"
        }
    }
    
    mutating func checkInvoices() {
        
        pendingInvoices = []
        
        for card in CreditCardsRepository.shared.list {
            
            let invoiceTotal = card.invoiceTotal(monthDate: monthDisplayed)
            
            if abs(invoiceTotal) > 0 {
                pendingInvoices.append(card.getInvoice(month: monthDisplayed))
            }
        }
        
    }
    
    mutating func resetFilteredTransactions() {
        self.filteredTransactions = TransactionsRepository.shared.list
        reordenateTransactions()
    }
    
    mutating func filterTransactions(parameters: FilteringParameters? = nil, textSearch: String? = globalStrings.emptyString) {
        
        resetFilteredTransactions()
        
        self.filteredTransactions = filteringWorker.filterTransactions(transactions: self.filteredTransactions, parameters: parameters, monthDisplayed: monthDisplayed)
        
        if let text = textSearch, !text.isEmpty {
            self.filteredTransactions = filteringWorker.searchForTransactions(textSearch, transactions: self.filteredTransactions)
        }
        
    }
    
}
