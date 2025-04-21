//
//  creditCardExpenses.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/04/23.
//

import Foundation

struct CreditCardExpense: FirestoreObject, Transactions, Codable, Equatable  {
   
    private(set) var  id: String = UUID().uuidString
    var desc: String
    var amount: Double
    var categoryIndex: Int
    var date: String
    var type: TransactionType
    var month: MonthDate
    var isMonthly: Bool
    var paymentStatus: PaymentStatus
    var installment: Installment
    var attachmentUrl: String?
    var sourceId: String
    var obs: String
    
    init(desc: String, amount: Double, categoryIndex: Int, date: String, type: TransactionType, isMonthly: Bool, paymentStatus: PaymentStatus, month: MonthDate, installment: Installment, sourceId: String, obs: String) {
        self.desc = desc
        self.amount = amount
        self.categoryIndex = categoryIndex
        self.date = date
        self.type = type
        self.isMonthly = isMonthly
        self.paymentStatus = paymentStatus
        self.month = month
        self.installment = installment
        self.attachmentUrl = nil
        self.sourceId = sourceId
        self.obs = obs
    }
    
}

struct Installment: Codable, Equatable {
    var enabled: Bool
    var current: Int
    var total: Int
    
    init(enabled: Bool = false, current: Int = 1, total: Int = 1) {
        self.enabled = enabled
        self.current = current
        self.total = total
    }
}
