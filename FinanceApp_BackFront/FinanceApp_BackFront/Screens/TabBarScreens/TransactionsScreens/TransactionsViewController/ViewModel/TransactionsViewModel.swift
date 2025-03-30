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
    
    public func getTransactionsCount() -> Int {
        return filteredTransactions.count
    }
    
    public func getItemTransactions(_ index: Int) -> any Transactions {
        return filteredTransactions[index]
    }
    
    public func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 85)
    }
    
    func getParameters() -> FilteringParameters {
        return filteringWorker.parameters
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
            return months[monthDisplayed.month] ?? globalStrings.january
        } else {
            return "\(months[monthDisplayed.month] ?? globalStrings.january) \(monthDisplayed.year)"
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
        filteredTransactions.append(contentsOf: pendingInvoices)
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
