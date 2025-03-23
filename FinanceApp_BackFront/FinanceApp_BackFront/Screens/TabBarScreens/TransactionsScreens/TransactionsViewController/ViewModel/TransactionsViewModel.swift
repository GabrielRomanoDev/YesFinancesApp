//
//  TransactionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 20/04/23.
//

import Foundation

struct TransactionsViewModel {
    
    var filteringWorker: TransactionsFilterWorker = TransactionsFilterWorker()
    var filteredTransactions: [AccountTransaction]? = nil
    var pendingInvoices: [CreditCardExpense] = []
    
    public func reordenateTransactions() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = globalStrings.dateFormat
        
        TransactionsRepository.shared.list = TransactionsRepository.shared.list.sorted(by: { transaction1, transaction2 in
            let data1 = dateFormatter.date(from: transaction1.date)!
            let data2 = dateFormatter.date(from: transaction2.date)!
            return data1 > data2
        })
        
    }
    
    public func getTransactionsCount() -> Int {
        
        if let filtered = filteredTransactions {
            return filtered.count + pendingInvoices.count
        } else {
            return TransactionsRepository.shared.list.count + pendingInvoices.count
        }
        
    }
    
    public func getItemTransactions(_ index:Int) -> any Transactions {
        
        if let filtered = filteredTransactions {
            return filtered[index]
        } else {
            return TransactionsRepository.shared.list[index]
        }
        
    }
    
    public func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 85)
    }
    
    mutating func checkInvoices() {
        
        pendingInvoices = []
        
        for card in CreditCardsRepository.shared.list {
            
//            print("cartão: \(String(describing: card.desc))")
//            print("closing day: \(String(describing: card.closingDay))")
//            print("due day: \(String(describing: card.dueDay))")
//            print("nextDueDate: \(String(describing: card.nextDueDate.toString()))")
//            card.printStartAndEndDates()
//            print("-----------------------------------------")

            if abs(card.currentInvoiceTotal) > 0 {
                pendingInvoices.append(
                    CreditCardExpense(
                        desc: "Fatura \(card.desc)",
                        amount: card.currentInvoiceTotal,
                        categoryIndex: 0,
                        date: card.nextDueDate.toString(),
                        type: .expense,
                        sourceId: card.id,
                        paymentStatus: .future,
                        invoiceMonth: Date().getMonth(),
                        obs: " "
                    )
                )
            }
        }
        
    }
    
    mutating func filterTransactions(parameters: FilteringParameters, textSearch: String? = "") {
        filteredTransactions = filteringWorker.filterTransactions(parameters: parameters)
        filteredTransactions = filteringWorker.searchForTransactions(textSearch)
    }
    
    mutating func searchForTransactions(_ text: String?) {
        if filteringWorker.filteredTransactions.isEmpty {
            filteringWorker.filteredTransactions = TransactionsRepository.shared.list
        }
        filteredTransactions = filteringWorker.searchForTransactions(text)
    }
    
}
