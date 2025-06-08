////
////  TransactionsViewModel.swift
////  FinanceApp_BackFront
////
////  Created by Gabriel Luz Romano on 20/04/23.
////

import Foundation

struct InvoiceViewModel {
    
    private let creditCard: CreditCard
    private(set) var invoice: Invoice
    private var filteringWorker: TransactionsFilterWorker = TransactionsFilterWorker(filterType: .invoiceExepenses)
    private var cardExpenses: [CreditCardExpense] = []
    private var filteredTransactions: [any Transactions] = CreditCardExpensesRepository.shared.list
    
    init(invoice: Invoice) {
        self.invoice = invoice
        self.creditCard = CreditCardsRepository.shared.list.first(where: { $0.id == invoice.sourceId } )!
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
        invoice = creditCard.getInvoice(month: invoice.month)
    }
    
    func getTransactionsCount() -> Int {
        return filteredTransactions.count
    }
    
    func getExpense(_ index: Int) -> any Transactions {
        return filteredTransactions[index]
    }
    
    func getSizeForCell(index: Int, viewWidth: CGFloat) -> CGSize {
        
        if index == 0 {
            return CGSize(width: viewWidth, height: 255)
        } else {
            return CGSize(width: viewWidth - 30, height: 74)
        }
        
    }
    
    func getParameters() -> FilteringParameters {
        return filteringWorker.parameters
    }
    
    mutating func displayNextMonth() {
        
        invoice.month.nextMonth()
        invoice = creditCard.getInvoice(month: invoice.month)
        filteringWorker.parameters.dates.enabled = false
        
    }
    
    mutating func displayLastMonth() {
        
        invoice.month.lastMonth()
        invoice = creditCard.getInvoice(month: invoice.month)
        filteringWorker.parameters.dates.enabled = false
        
    }
    
    func getMonthName(dateFilter: TransactionFilteringDates? = nil) -> String {
        
        if let date = dateFilter, date.enabled {
            return "\(date.initial) - \(date.final)"
        }
        
        if invoice.month.year == Calendar.current.component(.year, from: Date()) {
            return monthsText[invoice.month.month]!
        } else {
            return "\(monthsText[invoice.month.month]!) \(invoice.month.year)"
        }
    }
    
    mutating func filterTransactions(parameters: FilteringParameters? = nil, textSearch: String? = "") {
        
        self.filteredTransactions = self.cardExpenses
        
        self.filteredTransactions = filteringWorker.filterTransactions(transactions: self.filteredTransactions, parameters: parameters, monthDisplayed: invoice.month)
        
        if let text = textSearch, !text.isEmpty {
            self.filteredTransactions = filteringWorker.searchForTransactions(textSearch, transactions: self.filteredTransactions)
        }
        
    }
    
    mutating func payInvoice() {
    
        var expensesToPay: [CreditCardExpense] = []
        var totalAmount = 0.0
        
        let _ = CreditCardExpensesRepository.shared.list.enumerated().filter { (index, expense) in
            if expense.date.toDate() != nil {
                if expense.sourceId == creditCard.id && expense.month == invoice.month && expense.paymentStatus != .paid {
                    var paidExpense = expense
                    paidExpense.paymentStatus = .paid
                    CreditCardExpensesRepository.shared.list[index] = paidExpense
                    expensesToPay.append(paidExpense)
                    totalAmount += expense.amount
                }
            }
            return false
        }
        
        FirestoreService.shared.setObjectsList(objects: expensesToPay, subCollection: firebaseSubCollectionNames.creditCardExpenses) { result in
            if result != "Success" {
                print(result)
            }
        }
        
        let invoiceMonth = self.invoice.month
        
        self.invoice = self.creditCard.getInvoice(month: invoiceMonth)
        
    }
    
    func deleteExpense(_ filteredIndex: Int, completion: @escaping (String) -> Void) {
        
        if let index = CreditCardExpensesRepository.shared.list.firstIndex(where: {$0.id == filteredTransactions[filteredIndex].id}) {
            
            FirestoreService.shared.deleteObject(id: CreditCardExpensesRepository.shared.list[index].id, subCollection: firebaseSubCollectionNames.creditCardExpenses) { result in
                CreditCardExpensesRepository.shared.list.remove(at: index)
                completion(result)
            }
            
        }
        
    }
    
}
