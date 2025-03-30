////
////  TransactionsViewModel.swift
////  FinanceApp_BackFront
////
////  Created by Gabriel Luz Romano on 20/04/23.
////

import Foundation

struct InvoiceViewModel {
    
    let service = FirestoreService(subCollectionName: firebaseSubCollectionNames.creditCardExpenses)
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
    
    public func getTransactionsCount() -> Int {
        return filteredTransactions.count
    }
    
    public func getExpense(_ index: Int) -> any Transactions {
        return filteredTransactions[index]
    }
    
    func getSizeForCell(index: Int, viewWidth: CGFloat) -> CGSize {
        
        if index == 0 {
            switch invoice.paymentStatus {
            case .open, .overdue, .pendent:
                return CGSize(width: viewWidth, height: 176)
            case .paid, .future, .zeroed:
                return CGSize(width: viewWidth, height: 130)
            }
        } else {
            return CGSize(width: viewWidth - 30, height: 85)
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
            return months[invoice.month.month]!
        } else {
            return "\(months[invoice.month.month]!) \(invoice.month.year)"
        }
    }
    
    mutating func filterTransactions(parameters: FilteringParameters? = nil, textSearch: String? = "") {
        
        self.filteredTransactions = self.cardExpenses
        
        self.filteredTransactions = filteringWorker.filterTransactions(transactions: self.filteredTransactions, parameters: parameters, monthDisplayed: invoice.month)
        
        if let text = textSearch, !text.isEmpty {
            self.filteredTransactions = filteringWorker.searchForTransactions(textSearch, transactions: self.filteredTransactions)
        }
        
    }
    
    func payInvoice(completion: @escaping () -> Void) {
    
        var expensesToPay: [CreditCardExpense] = []
        var totalAmount = 0.0
        
        var invoiceExpenses = CreditCardExpensesRepository.shared.list.enumerated().filter { (index, expense) in
            if let transactionDate = expense.date.toDate() {
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
        
        if (BankAccountsRepository.shared.list.count >= 1) {
            
            let accountSourceId = BankAccountsRepository.shared.list[0].id
            
            let invoicePaymentTransaction = AccountTransaction(
                desc: "Pagamento Fatura \(creditCard.desc)",
                amount: totalAmount,
                categoryIndex: 0,
                date: Date().toString(),
                type: .expense,
                sourceId: accountSourceId,
                obs: ""
            )
            
            TransactionsRepository.shared.list.append(invoicePaymentTransaction)
            
            service.setObject(invoicePaymentTransaction, subCollectionName: firebaseSubCollectionNames.transactions) { result in
                
                if result != "Success" {
                    print(result)
                }
            }
            
        }
        
        service.setObjectsList(objects: expensesToPay) { result in
            if result != "Success" {
                print(result)
            }
        }
        
    }
    
}
