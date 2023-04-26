//
//  TransactionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 20/04/23.
//

import Foundation

struct TransactionsViewModel {
    
    
    public mutating func setNewTransaction(_ newTransaction:Transactions) {
        transactions.append(newTransaction)
    }
    
    public func getTransactionsCount() -> Int {
        return transactions.count
    }
    
    public func getItemTransactions(_ index:Int) -> Transactions {
        return transactions[index]
    }
    
    public func getCellSize(viewWidth:Int) -> CGSize {
        return CGSize (width: viewWidth - 30, height: 85)
    }
}

