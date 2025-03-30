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
    var isMonthly: Bool?
    var paymentStatus: PaymentStatus
    var installment: installment?
    var attachmentUrl: String?
    var sourceId: String
    var obs: String
    
    init(desc: String, amount: Double, categoryIndex: Int, date: String, type: TransactionType, paymentStatus: PaymentStatus, month: MonthDate, sourceId: String, obs: String) {
        self.desc = desc
        self.amount = amount
        self.categoryIndex = categoryIndex
        self.date = date
        self.type = type
        self.isMonthly = nil
        self.paymentStatus = paymentStatus
        self.month = month
        self.installment = nil
        self.attachmentUrl = nil
        self.sourceId = sourceId
        self.obs = obs
    }
    
}

struct installment: Codable, Equatable {
    var current: Int
    var total: Int
}
