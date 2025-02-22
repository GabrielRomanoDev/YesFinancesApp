//
//  TransactionRepository.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 18/02/25.
//

class TransactionsRepository {
    
    static let shared = TransactionsRepository()
    
    var list: [AccountTransaction] = []
    
    private init(){}
    
}
