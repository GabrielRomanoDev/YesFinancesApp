//
//  Invoice.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/03/25.
//

import Foundation

struct Invoice: Transactions {
    
    private(set) var id: String = UUID().uuidString
    var desc: String
    var amount: Double
    var categoryIndex: Int
    var date: String
    var closingDate: String
    var dueDate: String
    var type: TransactionType
    var sourceId: String
    var paymentStatus: PaymentStatus
    var month: MonthDate
    var attachmentUrl: String?
    var isMonthly: Bool?
    
    init(desc: String, amount: Double, closingDate: String, dueDate: String, sourceId: String, paymentStatus: PaymentStatus, month: MonthDate) {
        self.desc = desc
        self.amount = amount
        self.categoryIndex = 0
        self.date = dueDate
        self.closingDate = closingDate
        self.dueDate = dueDate
        self.type = .expense
        self.sourceId = sourceId
        self.paymentStatus = paymentStatus
        self.month = month
    }
    
}
