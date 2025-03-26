////
////  TransactionsViewModel.swift
////  FinanceApp_BackFront
////
////  Created by Gabriel Luz Romano on 20/04/23.
////

import Foundation

struct InvoiceViewModel {
    
    private(set) var invoice: Invoice
    private var filteringWorker: TransactionsFilterWorker = TransactionsFilterWorker()
    private var cardExpenses: [CreditCardExpense] = []
    private var filteredTransactions: [any Transactions] = CreditCardExpensesRepository.shared.list
    
    init(invoice: Invoice) {
        self.invoice = invoice
        self.fetchExpenses()
    }
    
    public mutating func reordenateTransactions() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = globalStrings.dateFormat
        
        self.cardExpenses = self.cardExpenses.sorted(by: { transaction1, transaction2 in
            let data1 = dateFormatter.date(from: transaction1.date)!
            let data2 = dateFormatter.date(from: transaction2.date)!
            return data1 > data2
        })
        
    }

    mutating func fetchExpenses() {
        self.cardExpenses = CreditCardExpensesRepository.shared.list.filter { transaction in
            return transaction.sourceId == invoice.sourceId
        }
        
        reordenateTransactions()
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
        
        invoice.month.month += 1
        if invoice.month.month > 12 {
            invoice.month.month = 1
            invoice.month.year += 1
        }
        filteringWorker.parameters.dates.enabled = false
        
        card.bankName = ""
        
    }
    
    mutating func displayLastMonth() {
        
        invoice.month.month -= 1
        if invoice.month.month < 1 {
            invoice.month.month = 12
            invoice.month.year -= 1
        }
        filteringWorker.parameters.dates.enabled = false
        
    }
    
    func getMonthName(dateFilter: TransactionFilteringDates? = nil) -> String {
        
        if let date = dateFilter, date.enabled {
            return "\(date.initial) - \(date.final)"
        }
        
        if invoice.month.year == Calendar.current.component(.year, from: Date()) {
            return months[invoice.month.month]!
        } else {
            return "\(months[invoice.month.month]!) \(invoice.month.year)"
        }
    }
    
    mutating func filterTransactions(parameters: FilteringParameters? = nil, textSearch: String? = "") {
        
        self.filteredTransactions = self.cardExpenses
        
        self.filteredTransactions = filteringWorker.filterTransactions(transactions: self.filteredTransactions, parameters: parameters, monthDisplayed: self.invoice.month)
        
        if let text = textSearch, !text.isEmpty {
            self.filteredTransactions = filteringWorker.searchForTransactions(textSearch, transactions: self.filteredTransactions)
        }
        
    }
    
    func payInvoice() {
        print("Paga a fatura")
    }
    
}
