//
//  TransactionProtocol.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/02/25.
//

protocol Transactions: Codable, Equatable {
    var id: String {get}
    var desc: String {get set}
    var amount: Double {get set}
    var categoryIndex: Int {get set}
    var date: String {get set}
    var type: TransactionType {get set}
    var isMonthly: Bool? {get set}
    var month: MonthDate {get set}
    var attachmentUrl: String?  {get set}
    var sourceId: String {get set}
}
