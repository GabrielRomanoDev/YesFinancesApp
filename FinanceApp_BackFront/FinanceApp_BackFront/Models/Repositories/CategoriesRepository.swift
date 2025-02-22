//
//  CategoriesRepository.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/02/25.
//

class CategoriesRepository {
    
    static let shared = CategoriesRepository()
    
    var expenses: [TransactionCategory] = []
    var incomes: [TransactionCategory] = []
    
    private init(){}
    
}
