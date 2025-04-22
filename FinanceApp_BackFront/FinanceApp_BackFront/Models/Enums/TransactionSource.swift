//
//  ExpenseSource.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

protocol TransactionSource {
    var desc: String { get set }
    var bank: Banks { get set }
}
