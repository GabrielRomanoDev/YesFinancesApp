//
//  CreditCardExpensesRepository.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/02/25.
//

class CreditCardExpensesRepository {
    
    static let shared = CreditCardExpensesRepository()
    
    var list: [CreditCardExpense] = []
    
    private init(){}
    
}
