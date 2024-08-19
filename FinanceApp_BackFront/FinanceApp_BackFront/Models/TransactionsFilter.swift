//
//  TransactionsFilter.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 15/07/24.
//

import Foundation

struct TransactionsFilter {
    var type: [TransactionType]
    var status: [TransactionStatus]
    var accounts: [BankAccount]
    var creditCards: [CreditCard]
    var categories: [ListedCategories]
}

enum TransactionStatus {
    case resolved
    case pending
    case future
}
