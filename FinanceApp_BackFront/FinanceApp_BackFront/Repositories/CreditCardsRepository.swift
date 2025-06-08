//
//  CreditCardsRepository.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/02/25.
//

class CreditCardsRepository {
    
    static let shared = CreditCardsRepository()
    
    var list: [CreditCard] = []
    
    private init(){}
    
}
