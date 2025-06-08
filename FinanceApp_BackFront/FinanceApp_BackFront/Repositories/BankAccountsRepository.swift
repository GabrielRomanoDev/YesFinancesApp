//
//  BankAccountsRepository.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/02/25.
//

class BankAccountsRepository {
    
    static let shared = BankAccountsRepository()
    
    var list: [BankAccount] = []
    
    private init(){}
    
}
