//
//  creditCard.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/23.
//

import Foundation

struct CreditCard: Codable, Equatable {
    
    private var id: String = UUID().uuidString
    var desc : String
    var limit: Double
    var bank : Banks
    var closingDay : Int
    var dueDate : Int
    var standardCard: Bool
    var obs:String
    
    var getId: String {
        return id
    }
    
    var invoiceTotal: Double {
        let filteredTransactions = creditCardExpenses.filter{ $0.cardId == id}
        return filteredTransactions.reduce(0, {$0 + $1.amount})
    }
    
    init (desc: String, limit: Double, bank: Banks, closingDay: Int, dueDate: Int, standardCard: Bool, obs: String) {
        self.desc = desc
        self.limit = limit
        self.bank = bank
        self.closingDay = closingDay
        self.dueDate = dueDate
        self.standardCard = standardCard
        self.obs = obs
    }
    
    public func adjustInvoice(newInvoice:Double){
        let valueNewTransaction:Double = newInvoice - invoiceTotal
        var transactionType:TransactionType
        
        if valueNewTransaction >= 0{
            transactionType = .income
        } else{
            transactionType = .expense
        }
        
        creditCardExpenses.append(CreditCardExpense(desc: moreOptionsStrings.updateAccountAmount, amount: valueNewTransaction, categoryIndex: 0, date: Date().toString(format: globalStrings.dateFormat), type: transactionType, cardId: id, obs: globalStrings.emptyString))
    }
    
}


