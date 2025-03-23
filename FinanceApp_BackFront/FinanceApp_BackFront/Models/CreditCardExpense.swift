//
//  creditCardExpenses.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/04/23.
//

import Foundation

struct CreditCardExpense: Transactions, Codable, Equatable  {
   
    private(set) var  id: String = UUID().uuidString
    var desc:String
    var amount:Double
    var categoryIndex:Int
    var date:String
    var type: TransactionType
    var sourceId:String
    var paymentStatus: PaymentStatus
    var invoiceMonth: MonthDate
    var obs:String
    
    init(desc: String, amount: Double, categoryIndex: Int, date: String, type: TransactionType, sourceId: String, paymentStatus: PaymentStatus, invoiceMonth: MonthDate, obs: String) {
        self.desc = desc
        self.amount = amount
        self.categoryIndex = categoryIndex
        self.date = date
        self.type = type
        self.sourceId = sourceId
        self.paymentStatus = paymentStatus
        self.invoiceMonth = invoiceMonth
        self.obs = obs
    }
    
}
