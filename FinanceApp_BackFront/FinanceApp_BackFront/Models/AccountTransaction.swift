//
//  File.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 05/04/23.
//

import Foundation

struct AccountTransaction: FirestoreObject, Transactions, Codable, Equatable {
    
    private(set) var id: String = UUID().uuidString
    var desc: String
    var amount: Double
    var categoryIndex: Int
    var date: String
    var type: TransactionType
    var month: MonthDate
    var isMonthly: Bool
    var attachmentUrl: String?
    var sourceId: String
    var obs: String
    
    init(desc: String, amount: Double, categoryIndex: Int, date: String, type: TransactionType, isMonthly: Bool, attachmentUrl: String? = nil, sourceId: String, obs: String) {
        self.desc = desc
        self.amount = amount
        self.categoryIndex = categoryIndex
        self.date = date
        self.type = type
        self.isMonthly = isMonthly
        self.attachmentUrl = attachmentUrl
        self.sourceId = sourceId
        self.obs = obs
        self.month = date.toDate()?.getMonth() ?? Date().getMonth()
    }
    
}
