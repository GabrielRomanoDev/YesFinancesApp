//
//  File.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 05/04/23.
//

import Foundation

struct Transactions: Codable, Equatable {
    
    private var id: String = UUID().uuidString
    var desc: String
    var amount: Double
    var categoryIndex: Int
    var date: String
    var type: TransactionType
    var accountId: String
    var obs: String
    
    var getId: String {
        return id
    }
    
    init(desc: String, amount: Double, categoryIndex: Int, date: String, type: TransactionType, accountId: String, obs: String) {
        self.desc = desc
        self.amount = amount
        self.categoryIndex = categoryIndex
        self.date = date
        self.type = type
        self.accountId = accountId
        self.obs = obs
    }
    
}


